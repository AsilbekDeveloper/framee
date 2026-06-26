import '../../i18n/strings.g.dart';

/// All user-facing strings.
/// Delegates to slang translations — changes automatically when locale switches.
/// Static const fields (charCountFormat, required) stay as-is (format templates).
abstract final class AppStrings {
  static Translations get _t => LocaleSettings.instance.currentTranslations;

  // ─── App ──────────────────────────────────────────────────
  static String get appName => _t.appName;
  static String get appTagline => _t.appTagline;

  // ─── Auth ─────────────────────────────────────────────────
  static String get signIn => _t.auth.signIn;
  static String get signUp => _t.auth.signUp;
  static String get createAccount => _t.auth.createAccount;
  static String get logOut => _t.auth.logOut;
  static String get logOutConfirm => _t.auth.logOutConfirm;
  static String get confirmEmailTitle => _t.auth.confirmEmailTitle;
  static String confirmEmailBody(String email) =>
      _t.auth.confirmEmailBody(email: email);
  static String get goToSignIn => _t.auth.goToSignIn;
  static String get resetPassword => _t.auth.resetPassword;
  static String get emailAddressLabel => _t.auth.emailAddressLabel;
  static String get passwordResetSent => _t.auth.passwordResetSent;
  static String get deleteAccount => _t.auth.deleteAccount;
  static String get email => _t.auth.email;
  static String get password => _t.auth.password;
  static String get confirmPassword => _t.auth.confirmPassword;
  static String get fullName => _t.auth.fullName;
  static String get emailPlaceholder => _t.auth.emailPlaceholder;
  static String get passwordPlaceholder => _t.auth.passwordPlaceholder;
  static String get minPasswordPlaceholder => _t.auth.minPasswordPlaceholder;
  static String get repeatPasswordPlaceholder => _t.auth.repeatPasswordPlaceholder;
  static String get fullNamePlaceholder => _t.auth.fullNamePlaceholder;
  static String get welcomeBack => _t.auth.welcomeBack;
  static String get forgotPassword => _t.auth.forgotPassword;
  static String get joinFramee => _t.auth.joinFramee;
  static String get dontHaveAccount => _t.auth.dontHaveAccount;
  static String get alreadyHaveAccount => _t.auth.alreadyHaveAccount;
  static String get bySigningUp => _t.auth.bySigningUp;
  static String get terms => _t.auth.terms;
  static String get privacyPolicy => _t.auth.privacyPolicy;
  static String get continueWithGoogle => _t.auth.continueWithGoogle;
  static String get orDivider => _t.auth.orDivider;

  // ─── Profile Setup ────────────────────────────────────────
  static String get setUpProfile => _t.setup.setUpProfile;
  static String get setUpProfileSub => _t.setup.setUpProfileSub;
  static String get username => _t.setup.username;
  static String get displayName => _t.setup.displayName;
  static String get bio => _t.setup.bio;
  static String get website => _t.setup.website;
  static String get usernamePlaceholder => _t.setup.usernamePlaceholder;
  static String get displayNamePlaceholder => _t.setup.displayNamePlaceholder;
  static String get bioPlaceholder => _t.setup.bioPlaceholder;
  static String get websitePlaceholder => _t.setup.websitePlaceholder;
  static String get optional => _t.setup.optional;
  static const String required = '*';
  static String get usernameAvailable => _t.setup.usernameAvailable;
  static String get usernameTaken => _t.setup.usernameTaken;
  static String get addProfilePhoto => _t.setup.addProfilePhoto;
  static String get changePhoto => _t.setup.changePhoto;
  static String get saveAndContinue => _t.setup.saveAndContinue;
  static String get skipForNow => _t.setup.skipForNow;

  // ─── Home ─────────────────────────────────────────────────
  static String get home => _t.home.title;
  static String get newPost => _t.home.newPost;
  static String get pullToRefresh => _t.home.pullToRefresh;

  // ─── Post ─────────────────────────────────────────────────
  static String get post => _t.post.post;
  static String get createPost => _t.post.createPost;
  static String get addPhoto => _t.post.addPhoto;
  static String get photoFormats => _t.post.photoFormats;
  static String get writeCaptionPlaceholder => _t.post.writeCaptionPlaceholder;
  static String get allPosts => _t.post.allPosts;
  static String get textOnly => _t.post.textOnly;
  static String get imageOnly => _t.post.imageOnly;
  static String get cropImage => _t.post.cropImage;
  static String get discardPost => _t.post.discardPost;
  static String get discardPostSub => _t.post.discardPostSub;
  static String get discardPostConfirm => _t.post.discardPostConfirm;
  static String get errorNotLoggedIn => _t.post.errorNotLoggedIn;
  static String get errorImageRequired => _t.post.errorImageRequired;
  static String get errorCaptionTooLong => _t.post.errorCaptionTooLong;
  static String get postDetail => _t.post.postDetail;
  static String get likes => _t.post.likes;
  static String get comments => _t.post.comments;
  static String get addCommentPlaceholder => _t.post.addCommentPlaceholder;
  static String get reply => _t.post.reply;
  static String get viewAllComments => _t.post.viewAllComments;
  static String get deletePost => _t.post.deletePost;
  static String get deletePostConfirm => _t.post.deletePostConfirm;
  static String get deleteComment => _t.post.deleteComment;
  static String get deleteCommentConfirm => _t.post.deleteCommentConfirm;
  static String get noCommentsYet => _t.post.noCommentsYet;
  static String get viewComments => _t.post.viewComments;
  static String get showLess => _t.post.showLess;
  static String get replyingTo => _t.post.replyingTo;
  static String get reportPost => _t.post.reportPost;
  static String get savePost => _t.post.savePost;
  static String get copyLink => _t.post.copyLink;
  static String get sharePost => _t.post.sharePost;
  static String get linkCopied => _t.post.linkCopied;
  static String get postSaved => _t.post.postSaved;
  static String get postDeleted => _t.post.postDeleted;
  static String get postPublished => _t.post.postPublished;
  static String get postReported => _t.post.postReported;
  static String get editPost => 'Edit Post';
  static String get postUpdated => 'Post updated';
  static String get discardChanges => 'Discard changes?';
  static String get discardChangesSub => 'Your changes will be lost.';

  // ─── Search ───────────────────────────────────────────────
  static String get search => _t.search.search;
  static String get discover => _t.search.discover;
  static String get searchUsersPlaceholder => _t.search.searchUsersPlaceholder;
  static String get people => _t.search.people;
  static String get explore => _t.search.explore;
  static String get textPostsSection => _t.search.textPostsSection;
  static String get followers => _t.search.followers;
  static String get mutual => _t.search.mutual;

  // ─── Profile ──────────────────────────────────────────────
  static String get profile => _t.profile.profile;
  static String get posts => _t.profile.posts;
  static String get followersLabel => _t.profile.followersLabel;
  static String get followingLabel => _t.profile.followingLabel;
  static String get editProfile => _t.profile.editProfile;
  static String get shareProfile => _t.profile.shareProfile;
  static String get profileLinkCopied => _t.profile.profileLinkCopied;
  static String get noTaggedPosts => _t.profile.noTaggedPosts;
  static String get noTaggedPostsSub => _t.profile.noTaggedPostsSub;

  // ─── Follow ───────────────────────────────────────────────
  static String get follow => _t.follow.follow;
  static String get followBack => _t.follow.followBack;
  static String get requested => _t.follow.requested;
  static String get following => _t.follow.following;
  static String get followSuccess => _t.follow.followSuccess;
  static String get unfollowConfirm => _t.follow.unfollowConfirm;

  // ─── Notifications ────────────────────────────────────────
  static String get notifications => _t.notifications.notifications;
  static String get markAllRead => _t.notifications.markAllRead;
  static String get allMarkedRead => _t.notifications.allMarkedRead;
  static String get newSection => _t.notifications.newSection;
  static String get earlier => _t.notifications.earlier;
  static String get likedYourPost => _t.notifications.likedYourPost;
  static String get andOthers => _t.notifications.andOthers;
  static String get startedFollowingYou => _t.notifications.startedFollowingYou;
  static String get commented => _t.notifications.commented;
  static String get wantsToFollowYou => _t.notifications.wantsToFollowYou;
  static String get commentedYourPost => _t.notifications.commentedYourPost;
  static String get mentionedYou => _t.notifications.mentionedYou;
  static String get accept => _t.notifications.accept;

  // ─── Settings ─────────────────────────────────────────────
  static String get settings => _t.settings.settings;
  static String get appearance => _t.settings.appearance;
  static String get darkMode => _t.settings.darkMode;
  static String get darkModeSub => _t.settings.darkModeSub;
  static String get language => _t.settings.language;
  static String get english => _t.misc.english;
  static String get uzbek => _t.misc.uzbek;
  static String get russian => _t.misc.russian;
  static String get privacySecurity => _t.settings.privacySecurity;
  static String get privacy => _t.settings.privacy;
  static String get privacySub => _t.settings.privacySub;
  static String get security => _t.settings.security;
  static String get securitySub => _t.settings.securitySub;
  static String get changePassword => _t.settings.changePassword;
  static String get saved => _t.settings.saved;
  static String get currentPassword => _t.settings.currentPassword;
  static String get newPassword => _t.settings.newPassword;
  static String get passwordChanged => _t.settings.passwordChanged;
  static String get passwordMismatch => _t.settings.passwordMismatch;
  static String get notificationsLabel => _t.settings.notificationsLabel;
  static String get pushNotifications => _t.settings.pushNotifications;
  static String get emailNotifications => _t.settings.emailNotifications;
  static String get about => _t.settings.about;
  static String get helpSupport => _t.settings.helpSupport;
  static String get termsOfService => _t.settings.termsOfService;
  static String get version => _t.settings.version;
  static String get versionValue => _t.settings.versionValue;
  static String get loggedOut => _t.settings.loggedOut;
  static String get accountDeletionRequested => _t.settings.accountDeletionRequested;
  static String get deleteAccountConfirm => _t.settings.deleteAccountConfirm;
  static String get fillAllFields => _t.settings.fillAllFields;

  // ─── Edit Profile ─────────────────────────────────────────
  static String get save => _t.editProfile.save;
  static String get profileUpdated => _t.editProfile.profileUpdated;
  static String get privateAccount => _t.editProfile.privateAccount;
  static String get privateAccountSub => _t.editProfile.privateAccountSub;
  static String get accountSettings => _t.editProfile.accountSettings;

  // ─── Followers ────────────────────────────────────────────
  static String get searchPlaceholder => _t.misc.searchPlaceholder;

  // ─── Errors ───────────────────────────────────────────────
  static String get somethingWentWrong => _t.errors.somethingWentWrong;
  static String get noInternetConnection => _t.errors.noInternetConnection;
  static String get tryAgain => _t.errors.tryAgain;
  static String get retry => _t.errors.retry;
  static String get errorOccurred => _t.errors.somethingWentWrong;
  static String get sessionExpired => _t.errors.sessionExpired;
  static String get errorInvalidCredentials => _t.errors.invalidCredentials;
  static String get errorEmailInUse => _t.errors.emailInUse;
  static String get errorEmailNotConfirmed => _t.errors.emailNotConfirmed;
  static String get errorWeakPassword => _t.errors.weakPassword;

  // ─── Empty States ─────────────────────────────────────────
  static String get noPostsYet => _t.empty.noPostsYet;
  static String get noPostsYetSub => _t.empty.noPostsYetSub;
  static String get savedSub => _t.empty.savedSub;
  static String get noTextPosts => _t.empty.noTextPosts;
  static String get noTextPostsSub => _t.empty.noTextPostsSub;

  // ─── Privacy info ─────────────────────────────────────────
  static String get pvAccountVisibility => _t.privacyInfo.accountVisibility;
  static String get pvAccountVisibilityBody =>
      _t.privacyInfo.accountVisibilityBody;
  static String get pvBlockedUsers => _t.privacyInfo.blockedUsers;
  static String get pvBlockedUsersBody => _t.privacyInfo.blockedUsersBody;
  static String get pvComments => _t.privacyInfo.comments;
  static String get pvCommentsBody => _t.privacyInfo.commentsBody;
  static String get pvLocationData => _t.privacyInfo.locationData;
  static String get pvLocationDataBody => _t.privacyInfo.locationDataBody;
  static String get noNotifications => _t.empty.noNotifications;
  static String get noNotificationsSub => _t.empty.noNotificationsSub;
  static String get noResults => _t.empty.noResults;
  static String get noResultsSub => _t.empty.noResultsSub;

  // ─── Misc ─────────────────────────────────────────────────
  static String get more => _t.misc.more;
  static String get cancel => _t.misc.cancel;
  static String get confirm => _t.misc.confirm;
  static String get close => _t.misc.close;
  static String get edit => _t.misc.edit;
  static String get delete => _t.misc.delete;
  static String get options => _t.misc.options;
  static String get send => _t.misc.send;
  static String get done => _t.misc.done;
  static String get postNotFound => _t.misc.postNotFound;
  static String get galleryOpened => _t.misc.galleryOpened;
  static const String charCountFormat = '{count} / {max}';
  static String get minutesAgo => _t.misc.minutesAgo;
  static String get hourAgo => _t.misc.hourAgo;
  static String get yesterday => _t.misc.yesterday;
  static String get of => _t.misc.of;
}
