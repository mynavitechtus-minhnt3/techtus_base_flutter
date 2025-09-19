# README Config Input

Điền các giá trị dự án trong khối JSON bên dưới.

```json
{
  "projectName": "YOUR_PROJECT_NAME",
  "description": "Your Flutter app description",
  "flutter": {
    "sdkVersion": "3.35.1"
  },
  "cocoapods": {
    "version": "1.16.2"
  },
  "android": {
    "versionName": "1.0.0",
    "versionCode": 1,
    "namespace": "com.yourcompany.yourapp.dev",
    "flavors": [
      "develop"
    ],
    "applicationIds": {
      "develop": "com.yourcompany.yourapp.dev",
      "qa": "com.yourcompany.yourapp.qa",
      "staging": "com.yourcompany.yourapp.staging",
      "production": "com.yourcompany.yourapp"
    },
    "appNames": {
      "develop": "Your App Dev",
      "qa": "Your App QA",
      "staging": "Your App Staging",
      "production": "Your App"
    },
    "applicationId": "com.yourcompany.yourapp.dev"
  },
  "ios": {
    "bundleIds": {
      "develop": "com.yourcompany.yourapp.dev",
      "qa": "com.yourcompany.yourapp.qa",
      "staging": "com.yourcompany.yourapp.staging",
      "production": "com.yourcompany.yourapp"
    },
    "displayNames": {
      "develop": "Your App Dev",
      "qa": "Your App QA",
      "staging": "Your App Staging",
      "production": "Your App"
    }
  },
  "envKeys": {
    "develop": {
      "APP_BASIC_AUTH_NAME": "dev_username",
      "APP_BASIC_AUTH_PASSWORD": "dev_password",
      "APP_DOMAIN": "https://api-dev.yourcompany.com"
    },
    "qa": {
      "APP_BASIC_AUTH_NAME": "qa_username",
      "APP_BASIC_AUTH_PASSWORD": "qa_password",
      "APP_DOMAIN": "https://api-qa.yourcompany.com"
    },
    "staging": {
      "APP_BASIC_AUTH_NAME": "stg_username",
      "APP_BASIC_AUTH_PASSWORD": "stg_password",
      "APP_DOMAIN": "https://api-staging.yourcompany.com"
    },
    "production": {
      "APP_BASIC_AUTH_NAME": "prod_username",
      "APP_BASIC_AUTH_PASSWORD": "prod_password",
      "APP_DOMAIN": "https://api.yourcompany.com"
    },
    "APP_BASIC_AUTH_NAME": {
      "APP_BASIC_AUTH_NAME": "dev_username",
      "APP_BASIC_AUTH_PASSWORD": "dev_password",
      "APP_DOMAIN": "https://api-dev.yourcompany.com"
    },
    "APP_BASIC_AUTH_PASSWORD": {
      "APP_BASIC_AUTH_NAME": "dev_username",
      "APP_BASIC_AUTH_PASSWORD": "dev_password",
      "APP_DOMAIN": "https://api-dev.yourcompany.com"
    },
    "APP_DOMAIN": {
      "APP_BASIC_AUTH_NAME": "dev_username",
      "APP_BASIC_AUTH_PASSWORD": "dev_password",
      "APP_DOMAIN": "https://api-dev.yourcompany.com"
    }
  },
  "fastlane": {
    "slackWebhook": "https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK",
    "issuerId": "your-apple-issuer-id",
    "firebaseToken": "your-firebase-token",
    "mentions": "@your-team",
    "message": "Please help verify this build.",
    "devFlavor": "develop",
    "qaFlavor": "qa",
    "stgFlavor": "staging",
    "android": {
      "firebaseAppIds": {
        "develop": "1:123456789012:android:your-dev-app-id",
        "qa": "1:123456789012:android:your-qa-app-id",
        "staging": "1:123456789012:android:your-staging-app-id"
      },
      "firebaseGroups": "your-test-group"
    },
    "ios": {
      "teamId": "YOUR_TEAM_ID",
      "keyId": "YOUR_KEY_ID",
      "keyFilepath": "./AuthKey_YOUR_KEY_ID.p8",
      "testFlightExternalGroups": "your-test-group",
      "appStoreIds": {
        "develop": "1234567890",
        "qa": "1234567891",
        "staging": "1234567892",
        "production": "1234567893"
      }
    }
  },
  "lefthook": {
    "projectCode": "NFT"
  },
  "constants": {
    "designDeviceWidth": 375.0,
    "designDeviceHeight": 812.0,
    "appMinTextScaleFactor": 0.9,
    "appMaxTextScaleFactor": 1.3,
    "initialPage": 1,
    "itemsPerPage": 30,
    "invisibleItemsThreshold": 3,
    "shimmerItemCount": 20,
    "fddMMyyyy": "dd/MM/yyyy",
    "fHHmm": "HH:mm",
    "fddMMyyyyHHmm": "dd/MM/yyyy HH:mm",
    "fyyyyMMdd": "yyyy-MM-dd",
    "numberFormat1": "#,###",
    "listGridTransitionDuration": 500,
    "generalDialogTransitionDuration": 200,
    "snackBarDuration": 3000,
    "termUrl": "https://www.chatwork.com/",
    "lineApiBaseUrl": "https://api.line.me/",
    "twitterApiBaseUrl": "https://api.twitter.com/",
    "goongApiBaseUrl": "https://rsapi.goong.io/",
    "firebaseStorageBaseUrl": "https://firebasestorage.googleapis.com/",
    "randomUserBaseUrl": "https://randomuser.me/api/",
    "resetPasswordLink": "nals://",
    "remoteConfigPath": "/config/RemoteConfig.json",
    "settingsPath": "/mypage/settings",
    "materialAppTitle": "App",
    "taskMenuMaterialAppColor": "Colors.green",
    "mobileOrientation": [
      "portraitUp",
      "portraitDown"
    ],
    "tabletOrientation": [
      "portraitUp",
      "portraitDown"
    ],
    "systemUiOverlay": "SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarBrightness: Brightness.light, statusBarIconBrightness: Brightness.light, systemNavigationBarColor: Colors.red, systemNavigationBarIconBrightness: Brightness.light,)",
    "fcmImage": "image",
    "fcmConversationId": "conversation_id",
    "connectTimeout": 30,
    "receiveTimeout": 30,
    "sendTimeout": 30,
    "maxRetries": 3,
    "firstRetryInterval": 1,
    "secondRetryInterval": 2,
    "thirdRetryInterval": 4,
    "defaultErrorResponseDecoderType": "ErrorResponseDecoderType.jsonObject",
    "defaultSuccessResponseDecoderType": "SuccessResponseDecoderType.dataJsonObject",
    "nickname": "nickname",
    "email": "email",
    "password": "password",
    "passwordConfirmation": "password_confirmation",
    "invalidRefreshToken": 1300,
    "invalidResetPasswordToken": 1302,
    "multipleDeviceLogin": 1602,
    "accountHasDeleted": 1603,
    "pageNotFound": 1051,
    "userNotFoundErrorId": "ERR-0001",
    "refreshTokenFailedErrorId": "ERR-0002",
    "basicAuthorization": "Authorization",
    "jwtAuthorization": "JWT-Authorization",
    "userAgentKey": "User-Agent",
    "bearer": "Bearer",
    "en": "EN",
    "ja": "JA",
    "male": 0,
    "female": 1,
    "other": 2,
    "unknown": -1,
    "parameterSeparator": ",",
    "parameterMaxLength": 500
  }
}
```

Lưu ý:
- Không commit secrets thật lên repo công khai.
- Chỉ cần sửa JSON này;
- Xem hướng dẫn chi tiết tại: [docs/generate_first_project.md](docs/generate_first_project.md)