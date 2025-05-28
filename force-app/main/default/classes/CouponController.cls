@RestResource(urlMapping='/coupons')
global class CouponController {
    @HttpPost 
    global static void validateCoupon() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        try {
            String requestBody = req.requestBody != null ? req.requestBody.toString() : '';

            if (String.isBlank(requestBody)) {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
                    'error' => 'Request body is empty.',
                    'isValid' => false
                }));
                return;
            }

            CartDTO cart;
            try {
                cart = (CartDTO) JSON.deserialize(requestBody, CartDTO.class);
            } catch (Exception e) {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
                    'error' => 'Invalid or malformed JSON.',
                    'isValid' => false
                }));
                return;
            }

            if (cart == null || String.isBlank(cart.couponCode)) {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
                    'error' => 'Coupon code cannot be null or empty',
                    'isValid' => false
                }));
                return;
            }

            CouponValidationResult result = CouponValidationService.validateCouponCode(cart.couponCode);
            if (!result.isValid) {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
                    'isValid' => false,
                    'error' => result.errorMessage
                }));
                return;
            }

            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
                'isValid' => true,
                'message' => 'Coupon is eligible',
                'coupon' => result.coupon,
                'promotion' => result.promotion
            }));

        } catch (Exception ex) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
                'isValid' => false,
                'error' => 'Unexpected error: ' + ex.getMessage()
            }));
        }
    }
}
