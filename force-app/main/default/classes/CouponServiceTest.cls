@isTest
private class CouponServiceTest {

    @testSetup
    static void setupTestData() {
       // Create a Promotion
Promotion__c promo = new Promotion__c(
    Name             = 'Test Promo',
    DiscountValue__c = 10,
    Type__c          = 'Percentage',
    ActiveFrom__c    = Date.today().addDays(-5),
    ActiveTo__c      = Date.today().addDays(5)
);
insert promo;

// Valid Coupon - active, not expired, under usage limit
Coupon__c validCoupon = new Coupon__c(
    Name               = 'ValidCoupon',
    Code__c            = 'VALID123',
    UsageLimit__c      = 5,
    UsageCount__c      = 2,
    Expiration_date__c = Date.today().addDays(3),
    IsActive__c        = true,
    PromotionId__c     = promo.Id
);
insert validCoupon;

// Inactive Coupon - not usable due to inactive status
Coupon__c inactiveCoupon = new Coupon__c(
    Name           = 'InactiveCoupon',
    Code__c        = 'INACTIVE',
    IsActive__c    = false,
    PromotionId__c = promo.Id,
    UsageLimit__c  = 5,
    UsageCount__c  = 0,
    Expiration_date__c = Date.today().addDays(3)
);
insert inactiveCoupon;

// Expired Coupon - past its expiration date
Coupon__c expiredCoupon = new Coupon__c(
    Name               = 'ExpiredCoupon',
    Code__c            = 'EXPIRED',
    Expiration_date__c = Date.today().addDays(-1),
    IsActive__c        = true,
    PromotionId__c     = promo.Id,
    UsageLimit__c  = 5,
    UsageCount__c  = 0
);
insert expiredCoupon;

// Coupon with usage limit reached
Coupon__c limitReachedCoupon = new Coupon__c(
    Name           = 'LimitCoupon',
    Code__c        = 'LIMITED',
    UsageLimit__c  = 1,
    UsageCount__c  = 1,
    IsActive__c    = true,
    PromotionId__c = promo.Id,
    Expiration_date__c = Date.today().addDays(3)
);
insert limitReachedCoupon;

    }

    @isTest
    static void testGetCouponByCouponCode() {
        Coupon__c coupon = CouponService.getCouponByCouponCode('VALID123');
        System.assertNotEquals(null, coupon, 'Coupon should be found');
        System.assertEquals('VALID123', coupon.Code__c, 'Coupon code should match');
    }

    @isTest
    static void testGetCouponByInvalidCode() {
        Coupon__c coupon = CouponService.getCouponByCouponCode('INVALIDCODE');
        System.assertEquals(null, coupon, 'Invalid code should return null');
    }

    @isTest
    static void testValidateCouponValid(){
        Coupon__c coupon = [SELECT Id, IsActive__c, PromotionId__r.Id, Expiration_date__c, UsageLimit__c, UsageCount__c
                            FROM Coupon__c WHERE Code__c = 'VALID123' LIMIT 1];
        Test.startTest();
       Boolean result = CouponService.validateCoupon(coupon);
        Test.stopTest();
        System.assert(result, 'Coupon should be valid');
        System.assertEquals(true, result, 'it should be valid');
    }

    @isTest
    static void testValidateCouponInactive() {
        Coupon__c coupon = [SELECT Id, IsActive__c, PromotionId__r.Id FROM Coupon__c WHERE Code__c = 'INACTIVE'];
        Test.startTest();
        try {
          Boolean result =  CouponService.validateCoupon(coupon);
            System.assert(false, 'Expected exception for inactive coupon');
        } catch (Exception e) {
            System.assertEquals('Coupon is not active', e.getMessage(), 'Expected inactive coupon exception');
        }
        Test.stopTest();
    }

    @isTest
    static void testValidateCouponExpired() {
        Coupon__c coupon = [SELECT Id, IsActive__c, Expiration_date__c, PromotionId__r.Id
                            FROM Coupon__c WHERE Code__c = 'EXPIRED'];
        Test.startTest();
        try {
          Boolean result =  CouponService.validateCoupon(coupon);
            System.assert(false, 'Expected exception for expired coupon');
        } catch (Exception e) {
            System.assertEquals('Coupon has expired', e.getMessage(), 'Expected expired coupon exception');
        }
        Test.stopTest();
    }

    @isTest
    static void testValidateCouponUsageLimitReached() {
        Coupon__c coupon = [SELECT Id, IsActive__c, UsageCount__c, UsageLimit__c, PromotionId__r.Id, Expiration_date__c
                            FROM Coupon__c WHERE Code__c = 'LIMITED'];
        Test.startTest();
        try {
            Boolean result = CouponService.validateCoupon(coupon);
            System.assert(false, 'Expected exception for usage limit');
        } catch (Exception e) {
            System.assertEquals('Coupon usage limit reached', e.getMessage(), 'Expected usage limit exception');
        }
        Test.stopTest();
    }

    @isTest
    static void testIncrementUsageCount() {
        Coupon__c coupon = [SELECT Id, UsageCount__c FROM Coupon__c WHERE Code__c = 'VALID123'];
        Decimal previousCount = coupon.UsageCount__c;
        Test.startTest();
        CouponService.incrementUsageCount(coupon);
        Test.stopTest();

        coupon = [SELECT UsageCount__c FROM Coupon__c WHERE Id = :coupon.Id];
        System.assertEquals(previousCount + 1, coupon.UsageCount__c, 'Usage count should have incremented');
    }

    @isTest
    static void testChangeIsActive() {
        Coupon__c coupon = [SELECT Id, IsActive__c FROM Coupon__c WHERE Code__c = 'VALID123'];
        Test.startTest();
        CouponService.changeIsActive(coupon, false);
        Test.stopTest();

        coupon = [SELECT IsActive__c FROM Coupon__c WHERE Id = :coupon.Id];
        System.assertEquals(false, coupon.IsActive__c, 'Coupon should now be inactive');
    }
}
