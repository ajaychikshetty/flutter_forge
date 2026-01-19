import 'package:appforge_cli/templates/auth_template.dart';

class ScreenTemplates {
  /// Generates a splash screen
  static String generateSplashScreen(String projectName) {
    return '''
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:$projectName/core/services/feature_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));
    
    if (mounted) {
      // Check if user has completed onboarding
      final onboardingCompleted = await FeatureService.isOnboardingCompleted();

      if (onboardingCompleted) {
        context.go('/');
      } else {
        context.go('/onboarding');
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    theme.colorScheme.surface,
                    theme.colorScheme.surface.withOpacity(0.8),
                  ]
                : [
                    theme.colorScheme.primary.withOpacity(0.1),
                    theme.colorScheme.secondary.withOpacity(0.1),
                  ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.4),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.rocket_launch_rounded,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    '$projectName',
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Welcome to Your App',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 60),
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
''';
  }

  /// Generates a responsive home screen with enhanced widgets
  static String generateHomeScreen(
    String projectName, {
    bool includeLocalization = true,
    bool includeChatbot = false,
  }) {
    // Conditional localization imports
    final localizationImports = includeLocalization
        ? '''
import '../../../core/providers/locale_provider.dart';
import '../../../l10n/app_localizations.dart';'''
        : '';

    final chatbotImports = includeChatbot
        ? "import '../../chatbot/screens/chatbot_screen.dart';"
        : '';

    // Helper function to get localized text or fallback to default
    String _getText(String key, String fallback) {
      return includeLocalization
          ? "AppLocalizations.of(context)!.$key"
          : "'$fallback'";
    }

    final localizationButton = includeLocalization
        ? '''
      PopupMenuButton<Locale>(
            tooltip: 'Select Language',
            icon: Row(
              children: [
                const Icon(Icons.language),
                const SizedBox(width: 6),
                Text(_nativeLanguageName(
                  provider_pkg.Provider.of<LocaleProvider>(context, listen: false)
                      .locale
                      .languageCode,
                )),
              ],
            ),
            itemBuilder: (context) {
              return AppLocalizations.supportedLocales.map((loc) {
                final name = _nativeLanguageName(loc.languageCode);
                return PopupMenuItem<Locale>(
                  value: loc,
                  child: Row(
                    children: [
                      if (loc.languageCode ==
                          provider_pkg.Provider.of<LocaleProvider>(context, listen: false)
                              .locale
                              .languageCode)
                        const Icon(Icons.check, size: 18)
                      else
                        const SizedBox(width: 18),
                      const SizedBox(width: 8),
                      Text(name),
                    ],
                  ),
                );
              }).toList();
            },
            onSelected: (loc) {
              provider_pkg.Provider.of<LocaleProvider>(context, listen: false).setLocale(loc);
            },
          ), '''
        : '';

    final chatbotHelperFunction = includeChatbot
        ? '''
  void _openChatbot() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChatbotScreen(),
      ),
    );
  }'''
        : '';

    final chatbotUI = includeChatbot
        ? '''
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverToBoxAdapter(
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                        child: InkWell(
                          onTap: _openChatbot,
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.purple.shade400,
                                        Colors.blue.shade400,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.chat_bubble_outline,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ${_getText('chatWithAI', 'Chat with AI')},
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        ${_getText('askQuestionsInstant', 'Ask questions and get instant answers')},
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurface
                                              .withOpacity(0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.4),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
'''
        : '';

    // Only include the language name helper if localization is enabled
    final languageHelperFunction = includeLocalization
        ? '''
// Helper function for native language names
String _nativeLanguageName(String code) {
  const names = {
    'ar': 'العربية',
    'bn': 'বাংলা',
    'en': 'English',
    'hi': 'हिंदी',
    'es': 'Español',
    'fr': 'Français',
    'de': 'Deutsch',
    'zh': '中文',
    'ja': '日本語',
    'ta': 'தமிழ்',
    'te': 'తెలుగు',
    'mr': 'मराठी',
    'gu': 'ગુજરાતી',
    'kn': 'ಕನ್ನಡ',
    'ml': 'മലയാളം',
    'pt': 'Português',
    'ru': 'Русский',
    'it': 'Italiano',
    'pl': 'Polski',
  };
  return names[code] ?? code;
}

'''
        : '';

    return '''
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
  import 'package:provider/provider.dart' as provider_pkg;
import '../../../shared/widgets/widgets.dart';
import '../../../core/services/feature_service.dart';
import '../../../core/modules/camera/camera_service.dart';
import '../../../core/modules/call/call_service.dart';
import '../../../core/modules/contacts/phone_contacts_service.dart';
import '../../../core/modules/contacts/contact.dart';
import '../../../core/modules/location/location_service.dart';
import 'package:geolocator/geolocator.dart';$localizationImports
  import '../../../core/providers/theme_mode_provider.dart';
$chatbotImports

$languageHelperFunction
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<File> _capturedImages = [];
  final List<Contact> _savedContacts = [];
  Contact? _selectedContact;
  final LocationService _locationService = LocationService();
  Position? _currentPosition;
  bool _isLoadingLocation = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: ${_getText('appTitle', 'Test App')},
        actions: [
          IconButton(
            tooltip: 'Toggle Theme',
            onPressed: () {
              provider_pkg.Provider.of<ThemeModeProvider>(context, listen: false)
                  .toggleTheme();
            },
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
          ),
          $localizationButton
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return RefreshIndicator(
              onRefresh: () async {
                await Future.delayed(const Duration(seconds: 1));
              },
              child: CustomScrollView(
                slivers: [
                  // Welcome Section
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ${_getText('welcome', 'Welcome Developer!')},
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            ${_getText('startCodingMessage', 'Start coding your app by customizing this home screen.')},
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  // Camera Section
                  if (FeatureService.isCameraEnabled ||
                      FeatureService.isImagePickerEnabled) ...[
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverToBoxAdapter(
                        child: Text(
                          ${_getText('photoGallery', 'Photo Gallery')},
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          children: [
                            if (FeatureService.isCameraEnabled)
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _takePhoto,
                                  icon: const Icon(Icons.camera_alt),
                                  label: Text(${_getText('takePhoto', 'Take Photo')}),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                ),
                              ),
                            if (FeatureService.isCameraEnabled &&
                                FeatureService.isImagePickerEnabled)
                              const SizedBox(width: 12),
                            if (FeatureService.isImagePickerEnabled)
                              Expanded(
                               child: OutlinedButton.icon(
                                  onPressed: _pickFromGallery,
                                  icon: const Icon(Icons.photo_library),
                                  label: Text(${_getText('pickImage', 'Pick Image')}),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 12)),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverToBoxAdapter(
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed:
                                _capturedImages.isEmpty ? null : _viewPhotos,
                            icon: const Icon(Icons.photo_album),
                            label: Text('View Photos \${_capturedImages.length}'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  ],

                  // Calling Section
                  if (FeatureService.isCallEnabled) ...[
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverToBoxAdapter(
                        child: Text(
                          ${_getText('calling', 'Calling')},
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverToBoxAdapter(
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.call,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ${_getText('makeACall', 'Make a Call')},
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        ${_getText('quicklyDialNumber', 'Quickly dial a phone number')},
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurface
                                              .withOpacity(0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: _startCall,
                                  icon: const Icon(Icons.call),
                                  label: Text(${_getText('startCall', 'Start Call')}),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  ],

                  // Contacts Section
                  if (FeatureService.isContactsEnabled) ...[
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverToBoxAdapter(
                        child: Text(
                          ${_getText('contacts', 'Contacts')},
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _pickContact,
                                icon: const Icon(Icons.person_add),
                                label: Text(${_getText('pickContact', 'Pick Contact')}),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _savedContacts.isEmpty
                                    ? null
                                    : _viewSavedContacts,
                                icon: const Icon(Icons.contacts),
                                label: Text('Saved (\${_savedContacts.length})'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_selectedContact != null) ...[
                      const SliverToBoxAdapter(child: SizedBox(height: 12)),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverToBoxAdapter(
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.person,
                                        size: 32,
                                        color: theme.colorScheme.primary,
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _selectedContact!.name,
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _selectedContact!.phoneNumber,
                                              style: theme.textTheme.bodyMedium,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: _callContact,
                                          icon: const Icon(Icons.call),
                                          label: Text(${_getText('call', 'Call')}),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: _copyContactNumber,
                                          icon: const Icon(Icons.copy),
                                          label: Text(${_getText('copy', 'Copy')}),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: _saveContact,
                                          icon: const Icon(Icons.bookmark_add),
                                          label: Text(${_getText('save', 'Save')}),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  ],

                  // Location Section
                  if (FeatureService.isLocationEnabled) ...[
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverToBoxAdapter(
                        child: Text(
                          'Location',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverToBoxAdapter(
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.location_on,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                           ${_getText('currentLocation', 'Current Location')},
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            ${_getText('getCurrentGPS', 'Get your current GPS coordinates')},
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              color: theme.colorScheme.onSurface
                                                  .withOpacity(0.6),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: _isLoadingLocation
                                          ? null
                                          : _getCurrentLocation,
                                      icon: _isLoadingLocation
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Icon(Icons.my_location),
                                      label: Text(_isLoadingLocation
                                          ? ${_getText('loading', 'Loading...')}
                                          : ${_getText('getLocation', 'Get Location')}),
                                    ),
                                  ],
                                ),
                                if (_currentPosition != null) ...[
                                  const SizedBox(height: 16),
                                  const Divider(),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildLocationInfoTile(
                                          context,
                                          icon: Icons.north,
                                          label: ${_getText('latitude', 'Latitude')},
                                          value: _currentPosition!.latitude
                                              .toStringAsFixed(6),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildLocationInfoTile(
                                          context,
                                          icon: Icons.east,
                                          label: ${_getText('longitude', 'Longitude')},
                                          value: _currentPosition!.longitude
                                              .toStringAsFixed(6),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildLocationInfoTile(
                                          context,
                                          icon: Icons.height,
                                          label: ${_getText('altitude', 'Altitude')},
                                          value:
                                              '\${_currentPosition!.altitude.toStringAsFixed(1)} m',
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildLocationInfoTile(
                                          context,
                                          icon: Icons.speed,
                                          label: ${_getText('accuracy', 'Accuracy')},
                                          value:
                                              '±\${_currentPosition!.accuracy.toStringAsFixed(1)} m',
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: _copyCoordinates,
                                      icon: const Icon(Icons.copy),
                                      label: Text(${_getText('copyCoordinates', 'Copy Coordinates')}),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  ],

                  // AI Chatbot Section
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        ${_getText('aiAssistant', 'AI Assistant')},
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
$chatbotUI
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),

                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _takePhoto() async {
    try {
      final file = await CameraService.pickImageFromCamera();
      if (file != null) {
        setState(() {
          _capturedImages.add(file);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(${_getText('photoCapturedSuccess', 'Photo captured successfully!')})),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: \$e')),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final file = await CameraService.pickImageFromGallery();
      if (file != null) {
        setState(() {
          _capturedImages.add(file);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(${_getText('imageAddedGallery', 'Image added from gallery!')})),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: \$e')),
        );
      }
    }
  }

  void _viewPhotos() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Photo Gallery (\${_capturedImages.length})',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: GridView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _capturedImages.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _showFullImage(_capturedImages[index]),
                    onLongPress: () => _deleteImage(index),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _capturedImages[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullImage(File imageFile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          backgroundColor: Colors.black,
          body: Center(
            child: InteractiveViewer(
              child: Image.file(imageFile),
            ),
          ),
        ),
      ),
    );
  }

  void _deleteImage(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(${_getText('deletePhoto', 'Delete Photo')}),
        content: Text(${_getText('deletePhotoConfirm', 'Are you sure you want to delete this photo?')}),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(${_getText('cancel', 'Cancel')}),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _capturedImages.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(${_getText('photoDeleted', 'Photo deleted')})),
              );
            },
            child: Text(${_getText('delete', 'Delete')}, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _startCall() async {
    try {
      final number = await _promptPhoneNumber();
      if (number == null || number.trim().isEmpty) return;
      await CallService.callNumber(number.trim());
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Call error: \$e')),
        );
      }
    }
  }

  Future<String?> _promptPhoneNumber() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(${_getText('enterPhoneNumber', 'Enter phone number')}),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              hintText: '+1 555 123 4567',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(${_getText('cancel', 'Cancel')}),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: Text(${_getText('call', 'Call')}),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickContact() async {
    try {
      final contact = await PhoneContactsService.pickContact();
      if (contact != null) {
        setState(() {
          _selectedContact = contact;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('\${${_getText('contactSelected', 'Contact selected')}}: \${contact.name}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: \$e')),
        );
      }
    }
  }

  void _callContact() async {
    if (_selectedContact == null) return;
    try {
      await CallService.callNumber(_selectedContact!.phoneNumber);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: \$e')),
        );
      }
    }
  }

  void _copyContactNumber() {
    if (_selectedContact == null) return;
    Clipboard.setData(
      ClipboardData(text: _selectedContact!.phoneNumber),
    ).then((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '\${_selectedContact!.phoneNumber} \${${_getText('numberCopied', 'copied!')}}',
            ),
          ),
        );
      }
    });
  }

  void _saveContact() {
    if (_selectedContact == null) return;

    final exists = _savedContacts.any(
      (c) => c.phoneNumber == _selectedContact!.phoneNumber,
    );

    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(${_getText('contactAlreadySaved', 'Contact already saved!')})),
      );
      return;
    }

    setState(() {
      _savedContacts.add(_selectedContact!);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '\${_selectedContact!.name} \${${_getText('contactSaved', 'saved!')}}',
          ),
        ),
      );
    }
  }

  void _viewSavedContacts() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Saved Contacts (\${_savedContacts.length})',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _savedContacts.length,
                itemBuilder: (context, index) {
                  final contact = _savedContacts[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Icon(
                        Icons.person,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: Text(contact.name),
                      subtitle: Text(contact.phoneNumber),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            child: Text(${_getText('call', 'Call')}),
                            onTap: () async {
                              try {
                                await CallService.callNumber(
                                  contact.phoneNumber,
                                );
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: \$e')),
                                  );
                                }
                              }
                            },
                          ),
                          PopupMenuItem(
                            child: Text(${_getText('copy', 'Copy')}),
                            onTap: () {
                              Clipboard.setData(
                                ClipboardData(text: contact.phoneNumber),
                              ).then((_) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '\${contact.phoneNumber} \${${_getText('numberCopied', 'copied!')}}',
                                      ),
                                    ),
                                  );
                                }
                              });
                            },
                          ),
                          PopupMenuItem(
                            child: Text(
                              ${_getText('delete', 'Delete')},
                              style: const TextStyle(color: Colors.red),
                            ),
                            onTap: () {
                              setState(() {
                                _savedContacts.removeAt(index);
                              });
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('\${contact.name} \${${_getText('contactDeleted', 'deleted')}}'),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  $chatbotHelperFunction
  
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final position = await _locationService.getCurrentLocation();
      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location retrieved successfully!')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: \$e')),
        );
      }
    }
  }

  void _copyCoordinates() {
    if (_currentPosition == null) return;
    final coords =
        '\${_currentPosition!.latitude}, \${_currentPosition!.longitude}';
    Clipboard.setData(ClipboardData(text: coords)).then((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('\${'Coordinates copied'}: \$coords')),
        );
      }
    });
  }

  Widget _buildLocationInfoTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
''';
  }

  /// Generates a login screen
  static String generateLoginScreen(String projectName) {
    return generateEmailPasswordLogin(projectName);
  }

  // AUTH SCREEN GENERATORS
  static String generateEmailPasswordLogin(String projectName) {
    return AuthScreenTemplates.generateEmailPasswordLogin(projectName);
  }

  static String generateEmailPasswordSignup(String projectName) {
    return AuthScreenTemplates.generateEmailPasswordSignup(projectName);
  }

  static String generateUsernamePasswordLogin(String projectName) {
    return AuthScreenTemplates.generateUsernamePasswordLogin(projectName);
  }

  static String generateUsernamePasswordSignup(String projectName) {
    return AuthScreenTemplates.generateUsernamePasswordSignup(projectName);
  }

  static String generatePhoneOTPLogin(String projectName) {
    return PhoneOTPAuthTemplates.generatePhoneOTPLogin(projectName);
  }

  static String generateOTPVerification(String projectName) {
    return PhoneOTPAuthTemplates.generateOTPVerification(projectName);
  }

  static String generateSocialLogin(String projectName) {
    return SocialAuthTemplates.generateSocialLogin(projectName);
  }

  static String generateUnifiedLogin(String projectName) {
    return UnifiedAuthTemplates.generateUnifiedLogin(projectName);
  }

  static String generateUnifiedSignup(String projectName) {
    return UnifiedAuthTemplates.generateUnifiedSignup(projectName);
  }
}
