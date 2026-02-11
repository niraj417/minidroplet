class ApiEndpoints {

  // static const String serverURL = "http://192.168.1.10:8080/adminapp_tinydroplets/appadmin/api";
  static const String serverURL = "https://testbackend.tinydroplets.com/api";
  // static const String serverURL = "http://43.204.111.100/api";
  // static const String serverURL = "http://43.204.111.100/api";
  // static const String serverURL = "https://backend.tinydroplets.com/api";
  // static const String serverURL = "http://13.234.75.223/api";
  // static const String serverURL = "https://appadmin.softdkc.com/api";

  // Auth
  static const String signupUrl = '${ApiEndpoints.serverURL}/user_register';
  static const String loginUrl = '${ApiEndpoints.serverURL}/user_login';
  static const String thirdPartyAuth = '${ApiEndpoints.serverURL}/user_thirdparty_auth';
   static const String deleteAccountUrl = '${ApiEndpoints.serverURL}/user_delete_account';
  static const String userProfile = '${ApiEndpoints.serverURL}/user_profile';
  static const String resendOtp = '${ApiEndpoints.serverURL}/user_resend_otp';
  static const String verifyOtp = '${ApiEndpoints.serverURL}/user_otp_verify';
  static const String confirmPassword =
      '${ApiEndpoints.serverURL}/reset_password';

  // Feed
  static const String feedSlider =
      '${ApiEndpoints.serverURL}/feed_slider_image';
  static const String feedPost = '${ApiEndpoints.serverURL}/feed_posts';
  static const String feedPostLike = '${ApiEndpoints.serverURL}/feed_post_like';
  static const String addFeedPostComment =
      '${ApiEndpoints.serverURL}/add_feed_post_comment';
  static const String replyFeedPostComment =
      '${ApiEndpoints.serverURL}/reply_feed_post_comment';
  static const String shareFeedPost =
      '${ApiEndpoints.serverURL}/feed_post_share';
  static const String ebookSlider =
      '${ApiEndpoints.serverURL}/ebook_slider_image';
  static const String allEbooks = '${ApiEndpoints.serverURL}/all_ebooks';
  static const String saveEbook = '${ApiEndpoints.serverURL}/save_ebook';
  static const String ebookDetail = '${ApiEndpoints.serverURL}/ebook_details';
  static const String createOrder = '${ApiEndpoints.serverURL}/create_order';
  static const String paymentStatus =
      '${ApiEndpoints.serverURL}/razorpay_payment';
  static const String purchasedEbook =
      '${ApiEndpoints.serverURL}/ebook_all_details';
  static const String applyCoupon =
      '${ApiEndpoints.serverURL}/apply_cupon_code';
  static const String allCoupon = '${ApiEndpoints.serverURL}/all_cupon_code';
  static const String removeCoupon =
      '${ApiEndpoints.serverURL}/remove_cupon_code';
  static const String searchEbook = '${ApiEndpoints.serverURL}/search_ebooks';
  static const String ebookCategory =
      '${ApiEndpoints.serverURL}/ebook_all_category';
  static const String ebookAllReview =
      '${ApiEndpoints.serverURL}/ebook_all_reviews';
  static const String addEbookRating =
      '${ApiEndpoints.serverURL}/add_ebbok_rating';
  static const String recentViewedEbook =
      '${ApiEndpoints.serverURL}/continue_reading_ebooks';
  static const String recipeCategory =
      '${ApiEndpoints.serverURL}/all_video_category';
  static const String recommendationRecipe =
      '${ApiEndpoints.serverURL}/recommendation_videos';
  static const String allRecipeVideos = '${ApiEndpoints.serverURL}/all_videos';
  // In ApiEndpoints.dart
  static const String allRecipeVideosByMultipleSubcategories = '${ApiEndpoints.serverURL}/all_videos_by_multiple_subcategories';
  static const String recipeSlider =
      '${ApiEndpoints.serverURL}/video_slider_image';

  static const String homepageRecipeSlider =
      '${ApiEndpoints.serverURL}/homepage_recipe_slider';

  static const String _recipeCategoryVideo =
      '${ApiEndpoints.serverURL}/all_videos?category_id=';

  static String recipeCategoryVideo(String id) {
    return '$_recipeCategoryVideo$id';
  }

  static const String recipeDetail = '${ApiEndpoints.serverURL}/video_detail';
  static const String saveVideo = '${ApiEndpoints.serverURL}/save_video';

  static const String recipePlaylist =
      '${ApiEndpoints.serverURL}/playlist_videos';
  static const String subcategoryList =
      '${ApiEndpoints.serverURL}/all_video_subcategory';
  static const String recipeCreateOrder =
      '${ApiEndpoints.serverURL}/create_order_video';
  static const String recipeApplyCouponCode =
      '${ApiEndpoints.serverURL}/apply_cupon_code_videos';
  static const String recipeRemoveCouponCode =
      '${ApiEndpoints.serverURL}/remove_cupon_code';
  static const String sendVideoTransaction =
      '${ApiEndpoints.serverURL}/razorpay_payment_video';
  static const String sendPlaylistTransaction =
      '${ApiEndpoints.serverURL}/razorpay_payment_playlist';
  static const String recipeAllPlaylist =
      '${ApiEndpoints.serverURL}/all_playlists';
  static const String recipePlaylistCreateOrder =
      '${ApiEndpoints.serverURL}/create_order_playlist';
  static const String recipePlaylistApplyCoupon =
      '${ApiEndpoints.serverURL}/apply_cupon_code_playlist';
  static const String recipePlaylistRemoveCoupon =
      '${ApiEndpoints.serverURL}/remove_cupon_code_playlist';

  // Search recipe
  static const String searchRecipeVideo =
      '${ApiEndpoints.serverURL}/search_videos';
  static const String recipeFilter = '${ApiEndpoints.serverURL}/video_filter';
  static const String savePlaylist = '${ApiEndpoints.serverURL}/save_playlist';

  static const String editProfile = '${ApiEndpoints.serverURL}/edit_profile';

  static const String savedEbook = '${ApiEndpoints.serverURL}/all_saved_ebooks';
  static const String removeSavedEbook =
      '${ApiEndpoints.serverURL}/remove_saved_ebooks';
  static const String savedVideo = '${ApiEndpoints.serverURL}/all_saved_videos';
  static const String removeSavedVideo =
      '${ApiEndpoints.serverURL}/remove_saved_videos';
  static const String savedPlaylist =
      '${ApiEndpoints.serverURL}/all_saved_playlist';
  static const String removePlaylist =
      '${ApiEndpoints.serverURL}/remove_saved_playlist';


  static const String notification = '${ApiEndpoints.serverURL}/notifications';
  static const String paypal =
      '${ApiEndpoints.serverURL}/paypal_paymentgateway';
  static const String orderHistory = '${ApiEndpoints.serverURL}/order_history';
  static const String googleAdmobEnable =
      '${ApiEndpoints.serverURL}/get_add_mob_status';
  static const String color = '${ApiEndpoints.serverURL}/app_color_code';

  static const String feedActivity =
      '${ApiEndpoints.serverURL}/feed_activity_list';
  static const String ebookAgeGroup =
      '${ApiEndpoints.serverURL}/ebook_age_group';
  static const String legacyAgeGroup =
      '${ApiEndpoints.serverURL}/legacy_age_group';
  static const String activityCenter = '${ApiEndpoints.serverURL}/activity_center';
  static const String trackMilestone = '${ApiEndpoints.serverURL}/track_milestone';
  static const String recommendation =
      '${ApiEndpoints.serverURL}/recommendation';

  static const String ingredientCategory =
      '${ApiEndpoints.serverURL}/ingrediants_category';
  static const String allIngredient =
      '${ApiEndpoints.serverURL}/all_ingrediants';
  static const String ingredientDetail =
      '${ApiEndpoints.serverURL}/ingrediant_details';
  static const String showSubcategories =
      '${ApiEndpoints.serverURL}/show_sub_category';
        static const String reportContentUrl =
      '${ApiEndpoints.serverURL}/report_content';

  static const String ebookPageCarousels = "${ApiEndpoints.serverURL}/ebook-page-carousels";

  static const String removeAdsPrice = '$serverURL/remove_ads_price';
  static const String removeAdsPayment = '$serverURL/remove_ads_payment';
  static const String checkUserRemovedAds = '$serverURL/check_user_removed_ads';

  static const String socialLinks = '$serverURL/get_social_links';
    static const String cms = '$serverURL/cms';

  static const String forgetPassword = '$serverURL/foget_password';
  static const String videoRating = '$serverURL/add_video_rating';
  static const String relatedRecipe = '$serverURL/related_recpie';
  static const String razorPay = '$serverURL/get_all_settings_data';

  static const String checkSubscription = '$serverURL/check_subscription_status';
  static const String subscriptionPayment = '$serverURL/subscription_payment';
  static const String createSubscriptionOrder = '$serverURL/create_subscription_order';
  static const String subscriptionPlans = '$serverURL/subscription_plans';
  static const String getUserSubscription = '$serverURL/get_user_subscription';
  static const String startFreeTrial = '$serverURL/start_free_trial';

  static const String homepageCarousels = '$serverURL/getHomepageCarousels';
}
