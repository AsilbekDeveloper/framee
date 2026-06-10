/// All user-facing strings.
/// Replace with AppLocalizations.of(context).xxx for l10n.
abstract final class AppStrings {
  // ─── App ──────────────────────────────────────────────────
  static const String appName = 'Framee';
  static const String appTagline = 'Capture your moments.\nShare your frame of life.';

  // ─── Auth ─────────────────────────────────────────────────
  static const String signIn = 'Sign In';
  static const String signUp = 'Sign Up';
  static const String createAccount = 'Create Account';
  static const String logOut = 'Log Out';
  static const String deleteAccount = 'Delete Account';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String fullName = 'Full Name';
  static const String emailPlaceholder = 'you@example.com';
  static const String passwordPlaceholder = '••••••••';
  static const String minPasswordPlaceholder = 'Min. 8 characters';
  static const String repeatPasswordPlaceholder = 'Repeat password';
  static const String fullNamePlaceholder = 'Your full name';
  static const String continueWithGoogle = 'Continue with Google';
  static const String welcomeBack = 'Welcome back 👋';
  static const String forgotPassword = 'Forgot password?';
  static const String joinFramee = 'Join Framee today';
  static const String dontHaveAccount = "Don't have an account?";
  static const String alreadyHaveAccount = 'Already have an account?';
  static const String bySigningUp =
      'By signing up you agree to our Terms and Privacy Policy';
  static const String terms = 'Terms';
  static const String privacyPolicy = 'Privacy Policy';

  // ─── Profile Setup ────────────────────────────────────────
  static const String setUpProfile = 'Set up your profile';
  static const String setUpProfileSub = 'Tell the world a bit about yourself';
  static const String username = 'Username';
  static const String displayName = 'Display Name';
  static const String bio = 'Bio';
  static const String website = 'Website';
  static const String usernamePlaceholder = '@username';
  static const String displayNamePlaceholder = 'Your display name';
  static const String bioPlaceholder = 'Tell people about yourself...';
  static const String websitePlaceholder = 'https://yoursite.com';
  static const String optional = '(optional)';
  static const String required = '*';
  static const String usernameAvailable = '✓ Username available';
  static const String usernameTaken = 'Username already taken';
  static const String addProfilePhoto = 'Add profile photo';
  static const String changePhoto = 'Change photo';
  static const String saveAndContinue = 'Save & Continue';
  static const String skipForNow = 'Skip for now';

  // ─── Home ─────────────────────────────────────────────────
  static const String home = 'Home';
  static const String newPost = 'New Post';
  static const String pullToRefresh = 'Pull to refresh';

  // ─── Post ─────────────────────────────────────────────────
  static const String post = 'Post';
  static const String createPost = 'New Post';
  static const String addPhoto = 'Add Photo';
  static const String photoFormats = 'JPG, PNG up to 20 MB';
  static const String writeCaptionPlaceholder = 'Write a caption...';
  static const String allPosts = 'All';
  static const String textOnly = 'Text only';
  static const String imageOnly = 'Image only';
  static const String cropImage = 'Crop Image';
  static const String discardPost = 'Discard post?';
  static const String discardPostSub = 'Your changes will be lost.';
  static const String discardPostConfirm = 'Discard';
  static const String errorNotLoggedIn = 'Please sign in to create a post.';
  static const String errorImageRequired = 'Please select an image first.';
  static const String errorCaptionTooLong = 'Caption exceeds 2200 character limit.';
  static const String postDetail = 'Post';
  static const String likes = 'likes';
  static const String comments = 'Comments';
  static const String addCommentPlaceholder = 'Add a comment...';
  static const String reply = 'Reply';
  static const String viewAllComments = 'View all comments';
  static const String deletePost = 'Delete Post';
  static const String reportPost = 'Report Post';
  static const String savePost = 'Save Post';
  static const String copyLink = 'Copy Link';
  static const String sharePost = 'Share Post';
  static const String linkCopied = 'Link copied!';
  static const String postSaved = 'Post saved!';
  static const String postDeleted = 'Post deleted';
  static const String postPublished = 'Post published!';
  static const String postReported = 'Post reported';

  // ─── Search ───────────────────────────────────────────────
  static const String search = 'Search';
  static const String discover = 'Discover';
  static const String searchUsersPlaceholder = 'Search users...';
  static const String people = 'People';
  static const String explore = 'Explore';
  static const String textPostsSection = 'Text posts';
  static const String followers = 'followers';
  static const String mutual = 'mutual';

  // ─── Profile ──────────────────────────────────────────────
  static const String profile = 'Profile';
  static const String posts = 'Posts';
  static const String followersLabel = 'Followers';
  static const String followingLabel = 'Following';
  static const String editProfile = 'Edit Profile';
  static const String shareProfile = 'Share Profile';
  static const String profileLinkCopied = 'Profile link copied!';
  static const String noTaggedPosts = 'No tagged posts';
  static const String noTaggedPostsSub =
      'When people tag you in posts, they\'ll appear here.';

  // ─── Follow ───────────────────────────────────────────────
  static const String follow = 'Follow';
  static const String following = 'Following';
  static const String followSuccess = 'Following!';
  static const String unfollowConfirm = 'Unfollow';

  // ─── Notifications ────────────────────────────────────────
  static const String notifications = 'Notifications';
  static const String markAllRead = 'Mark all read';
  static const String allMarkedRead = 'All marked as read';
  static const String newSection = 'New';
  static const String earlier = 'Earlier';
  static const String likedYourPost = 'liked your post';
  static const String andOthers = 'and others';
  static const String startedFollowingYou = 'started following you';
  static const String commented = 'commented:';

  // ─── Settings ─────────────────────────────────────────────
  static const String settings = 'Settings';
  static const String appearance = 'Appearance';
  static const String darkMode = 'Dark Mode';
  static const String darkModeSub = 'Switch between light and dark';
  static const String language = 'Language';
  static const String english = 'English';
  static const String privacySecurity = 'Privacy & Security';
  static const String privacy = 'Privacy';
  static const String privacySub = 'Account visibility, blocked users';
  static const String security = 'Security';
  static const String securitySub = 'Password, two-factor auth';
  static const String changePassword = 'Change Password';
  static const String saved = 'Saved';
  static const String currentPassword = 'Current Password';
  static const String newPassword = 'New Password';
  static const String passwordChanged = 'Password changed successfully!';
  static const String passwordMismatch = 'Parollar mos kelmadi';
  static const String notificationsLabel = 'Notifications';
  static const String pushNotifications = 'Push Notifications';
  static const String emailNotifications = 'Email Notifications';
  static const String about = 'About';
  static const String helpSupport = 'Help & Support';
  static const String termsOfService = 'Terms of Service';
  static const String version = 'Version';
  static const String versionValue = '1.0.0 MVP';
  static const String loggedOut = 'Logged out!';
  static const String accountDeletionRequested = 'Account deletion requested';

  // ─── Edit Profile ─────────────────────────────────────────
  static const String save = 'Save';
  static const String profileUpdated = 'Profile updated!';
  static const String privateAccount = 'Private Account';
  static const String privateAccountSub = 'Only approved followers see your posts';
  static const String showActivityStatus = 'Show Activity Status';
  static const String showActivityStatusSub = 'Let others see when you were last active';
  static const String accountSettings = 'Account settings';

  // ─── Followers ────────────────────────────────────────────
  static const String searchPlaceholder = 'Search...';

  // ─── Errors ───────────────────────────────────────────────
  static const String somethingWentWrong = 'Something went wrong';
  static const String noInternetConnection = 'No internet connection';
  static const String tryAgain = 'Try Again';
  static const String retry = 'Retry';
  static const String errorOccurred = 'Something went wrong';
  static const String sessionExpired = 'Session expired. Please sign in again.';

  // ─── Empty States ─────────────────────────────────────────
  static const String noPostsYet = 'No posts yet';
  static const String noPostsYetSub = 'When you post something, it will appear here.';
  static const String noNotifications = 'No notifications';
  static const String noNotificationsSub = 'When you get notifications, they\'ll appear here.';
  static const String noResults = 'No results found';
  static const String noResultsSub = 'Try a different search term.';

  // ─── Misc ─────────────────────────────────────────────────
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String close = 'Close';
  static const String edit = 'Edit';
  static const String delete = 'Delete';
  static const String options = 'Options';
  static const String galleryOpened = 'Gallery opened';
  static const String charCountFormat = '{count} / {max}';
  static const String minutesAgo = 'min ago';
  static const String hourAgo = 'hr ago';
  static const String yesterday = 'Yesterday';
  static const String of = 'of';
}
