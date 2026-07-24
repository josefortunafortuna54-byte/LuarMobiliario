import 'package:flutter_test/flutter_test.dart';
import 'package:luar_company/core/constants/app_constants.dart';

void main() {
  group('AppInfo', () {
    test('appName is Luar Mobiliario', () {
      expect(AppConstants.appName, 'Luar Mobiliario');
    });

    test('appTagline', () {
      expect(AppConstants.appTagline, 'Seu novo lar começa aqui');
    });

    test('appVersion is 1.0.0', () {
      expect(AppConstants.appVersion, '1.0.0');
    });
  });

  group('Contact', () {
    test('whatsappNumber is non-empty', () {
      expect(AppConstants.whatsappNumber, isNotEmpty);
    });

    test('whatsappMessage is non-empty', () {
      expect(AppConstants.whatsappMessage, isNotEmpty);
    });

    test('supportEmail is non-empty', () {
      expect(AppConstants.supportEmail, isNotEmpty);
    });

    test('supportPhone is non-empty', () {
      expect(AppConstants.supportPhone, isNotEmpty);
    });
  });

  group('Social Media URLs', () {
    test('instagramUrl starts with https', () {
      expect(AppConstants.instagramUrl, startsWith('https://'));
    });

    test('facebookUrl starts with https', () {
      expect(AppConstants.facebookUrl, startsWith('https://'));
    });

    test('linkedinUrl starts with https', () {
      expect(AppConstants.linkedinUrl, startsWith('https://'));
    });

    test('youtubeUrl starts with https', () {
      expect(AppConstants.youtubeUrl, startsWith('https://'));
    });
  });

  group('Storage Buckets', () {
    test('propertyImagesBucket', () {
      expect(AppConstants.propertyImagesBucket, 'property-images');
    });

    test('avatarBucket', () {
      expect(AppConstants.avatarBucket, 'avatars');
    });

    test('documentBucket', () {
      expect(AppConstants.documentBucket, 'documents');
    });

    test('productsBucket', () {
      expect(AppConstants.productsBucket, 'products');
    });
  });

  group('Database Tables', () {
    test('usersTable', () {
      expect(AppConstants.usersTable, 'users');
    });

    test('notificationsTable', () {
      expect(AppConstants.notificationsTable, 'notifications');
    });

    test('propertiesTable', () {
      expect(AppConstants.propertiesTable, 'properties');
    });

    test('landsTable', () {
      expect(AppConstants.landsTable, 'lands');
    });
  });

  group('Pagination', () {
    test('defaultPageSize is 20', () {
      expect(AppConstants.defaultPageSize, 20);
    });

    test('maxImageUploads is 10', () {
      expect(AppConstants.maxImageUploads, 10);
    });
  });

  group('Animation Durations', () {
    test('animationFast is 200ms', () {
      expect(AppConstants.animationFast, const Duration(milliseconds: 200));
    });

    test('animationNormal is 350ms', () {
      expect(AppConstants.animationNormal, const Duration(milliseconds: 350));
    });

    test('animationSlow is 500ms', () {
      expect(AppConstants.animationSlow, const Duration(milliseconds: 500));
    });

    test('fast < normal < slow', () {
      expect(
        AppConstants.animationFast.inMilliseconds,
        lessThan(AppConstants.animationNormal.inMilliseconds),
      );
      expect(
        AppConstants.animationNormal.inMilliseconds,
        lessThan(AppConstants.animationSlow.inMilliseconds),
      );
    });
  });

  group('Spacing', () {
    test('spacing values are in increasing order', () {
      expect(AppConstants.spacingXxs, lessThan(AppConstants.spacingXs));
      expect(AppConstants.spacingXs, lessThan(AppConstants.spacingSm));
      expect(AppConstants.spacingSm, lessThan(AppConstants.spacingMd));
      expect(AppConstants.spacingMd, lessThan(AppConstants.spacingLg));
      expect(AppConstants.spacingLg, lessThan(AppConstants.spacingXl));
      expect(AppConstants.spacingXl, lessThan(AppConstants.spacingXxl));
      expect(AppConstants.spacingXxl, lessThan(AppConstants.spacingXxxl));
    });

    test('spacingXxs is 2.0', () {
      expect(AppConstants.spacingXxs, 2.0);
    });

    test('spacingMd is 16.0', () {
      expect(AppConstants.spacingMd, 16.0);
    });

    test('spacingXxxl is 64.0', () {
      expect(AppConstants.spacingXxxl, 64.0);
    });
  });

  group('Border Radius', () {
    test('radius values are in increasing order', () {
      expect(AppConstants.radiusSm, lessThan(AppConstants.radiusMd));
      expect(AppConstants.radiusMd, lessThan(AppConstants.radiusLg));
      expect(AppConstants.radiusLg, lessThan(AppConstants.radiusXl));
      expect(AppConstants.radiusXl, lessThan(AppConstants.radiusFull));
    });

    test('radiusSm is 8.0', () {
      expect(AppConstants.radiusSm, 8.0);
    });

    test('radiusFull is 999.0 (pill shape)', () {
      expect(AppConstants.radiusFull, 999.0);
    });
  });

  group('Shadows', () {
    test('shadow values are in increasing order', () {
      expect(AppConstants.shadowSm, lessThan(AppConstants.shadowMd));
      expect(AppConstants.shadowMd, lessThan(AppConstants.shadowLg));
      expect(AppConstants.shadowLg, lessThan(AppConstants.shadowXl));
    });

    test('shadowSm is 2.0', () {
      expect(AppConstants.shadowSm, 2.0);
    });
  });

  group('Transaction Types', () {
    test('transactionTypes has 2 entries', () {
      expect(AppConstants.transactionTypes.length, 2);
    });

    test('contains Venda and Arrendamento', () {
      expect(AppConstants.transactionTypes, contains('Venda'));
      expect(AppConstants.transactionTypes, contains('Arrendamento'));
    });
  });

  group('Property Types', () {
    test('propertyTypes has 8 entries', () {
      expect(AppConstants.propertyTypes.length, 8);
    });

    test('contains expected types', () {
      expect(AppConstants.propertyTypes, contains('Casa'));
      expect(AppConstants.propertyTypes, contains('Apartamento'));
      expect(AppConstants.propertyTypes, contains('Terreno'));
      expect(AppConstants.propertyTypes, contains('Fazenda'));
      expect(AppConstants.propertyTypes, contains('Armazém'));
      expect(AppConstants.propertyTypes, contains('Escritório'));
      expect(AppConstants.propertyTypes, contains('Loja'));
      expect(AppConstants.propertyTypes, contains('Condomínio'));
    });
  });

  group('Bedroom Options', () {
    test('has 5 entries', () {
      expect(AppConstants.bedroomOptions.length, 5);
    });

    test('contains 1, 2, 3, 4, 5+', () {
      expect(AppConstants.bedroomOptions, ['1', '2', '3', '4', '5+']);
    });
  });

  group('Parking Options', () {
    test('has 4 entries', () {
      expect(AppConstants.parkingOptions.length, 4);
    });

    test('contains 1, 2, 3, 4+', () {
      expect(AppConstants.parkingOptions, ['1', '2', '3', '4+']);
    });
  });

  group('Regex Patterns', () {
    group('emailRegex', () {
      test('matches valid simple email', () {
        expect('user@test.com', matches(RegExp(AppConstants.emailRegex)));
      });

      test('matches email with subdomain', () {
        expect('user@mail.test.com', matches(RegExp(AppConstants.emailRegex)));
      });

      test('matches email with dots in local part', () {
        expect('first.last@test.com', matches(RegExp(AppConstants.emailRegex)));
      });

      test('matches email with plus', () {
        expect('user+tag@test.com', matches(RegExp(AppConstants.emailRegex)));
      });

      test('matches email with numbers', () {
        expect('user123@test.com', matches(RegExp(AppConstants.emailRegex)));
      });

      test('matches email with underscore and percent', () {
        expect(
          'user_name%test@test.com',
          matches(RegExp(AppConstants.emailRegex)),
        );
      });

      test('rejects email without @', () {
        expect('usertest.com', isNot(matches(RegExp(AppConstants.emailRegex))));
      });

      test('rejects email without domain', () {
        expect('user@', isNot(matches(RegExp(AppConstants.emailRegex))));
      });

      test('rejects email without TLD', () {
        expect('user@test', isNot(matches(RegExp(AppConstants.emailRegex))));
      });

      test('rejects email with spaces', () {
        expect(
          'user @test.com',
          isNot(matches(RegExp(AppConstants.emailRegex))),
        );
      });

      test('rejects empty string', () {
        expect('', isNot(matches(RegExp(AppConstants.emailRegex))));
      });
    });

    group('phoneRegex', () {
      test('matches Angolan number without country code', () {
        expect('923456789', matches(RegExp(AppConstants.phoneRegex)));
      });

      test('matches Angolan number with country code', () {
        expect('+244923456789', matches(RegExp(AppConstants.phoneRegex)));
      });

      test('matches number with country code and space', () {
        expect('+244 923456789', matches(RegExp(AppConstants.phoneRegex)));
      });

      test('matches number starting with 91', () {
        expect('912345678', matches(RegExp(AppConstants.phoneRegex)));
      });

      test('matches number starting with 99', () {
        expect('992345678', matches(RegExp(AppConstants.phoneRegex)));
      });

      test('rejects number not starting with 9', () {
        expect('823456789', isNot(matches(RegExp(AppConstants.phoneRegex))));
      });

      test('rejects too short number', () {
        expect('92345678', isNot(matches(RegExp(AppConstants.phoneRegex))));
      });

      test('rejects too long number', () {
        expect('9234567890', isNot(matches(RegExp(AppConstants.phoneRegex))));
      });

      test('rejects empty string', () {
        expect('', isNot(matches(RegExp(AppConstants.phoneRegex))));
      });
    });
  });

  group('Shared Preferences Keys', () {
    test('keyOnboardingComplete', () {
      expect(AppConstants.keyOnboardingComplete, 'onboarding_complete');
    });

    test('keyUserLogged', () {
      expect(AppConstants.keyUserLogged, 'user_logged');
    });

    test('keyUserId', () {
      expect(AppConstants.keyUserId, 'user_id');
    });

    test('keyThemeMode', () {
      expect(AppConstants.keyThemeMode, 'theme_mode');
    });

    test('keyLocale', () {
      expect(AppConstants.keyLocale, 'locale');
    });

    test('all keys are unique', () {
      final keys = {
        AppConstants.keyOnboardingComplete,
        AppConstants.keyUserLogged,
        AppConstants.keyUserId,
        AppConstants.keyThemeMode,
        AppConstants.keyLocale,
      };
      expect(keys.length, 5);
    });
  });
}
