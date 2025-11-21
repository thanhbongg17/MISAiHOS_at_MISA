class TwoFactorArguments {
  const TwoFactorArguments({
    required this.userName,
    required this.deviceId,
    required this.challengeMessage,
    this.useEmail = true,
    this.usePhoneNumber = false,
    this.useAppAuthenticator = false,
  });

  final String userName;
  final String deviceId;
  final String challengeMessage;
  final bool useEmail;
  final bool usePhoneNumber;
  final bool useAppAuthenticator;
}

