# README Input Configuration Guide

Hướng dẫn cấu hình các giá trị trong file `README.input.md`.

## Constants Configuration

### Design Constants
- `designDeviceWidth`: Chiều rộng thiết bị thiết kế (double)
- `designDeviceHeight`: Chiều cao thiết bị thiết kế (double)
- `appMinTextScaleFactor`: Hệ số scale text tối thiểu (double)
- `appMaxTextScaleFactor`: Hệ số scale text tối đa (double)

### Paging Constants
- `initialPage`: Trang bắt đầu (int)
- `itemsPerPage`: Số item mỗi trang (int)
- `invisibleItemsThreshold`: Ngưỡng item ẩn (int)

### Shimmer Constants
- `shimmerItemCount`: Số lượng item shimmer (int)

### Format Constants
- `fddMMyyyy`: Format ngày tháng "dd/MM/yyyy"
- `fHHmm`: Format giờ phút "HH:mm"
- `fddMMyyyyHHmm`: Format ngày giờ "dd/MM/yyyy HH:mm"
- `fyyyyMMdd`: Format ngày "yyyy-MM-dd"
- `numberFormat1`: Format số "#,###"

### Duration Constants
- `listGridTransitionDuration`: Thời gian chuyển đổi list/grid (milliseconds)
- `generalDialogTransitionDuration`: Thời gian chuyển đổi dialog (milliseconds)
- `snackBarDuration`: Thời gian hiển thị snackbar (milliseconds)

### URL Constants
- `termUrl`: URL điều khoản
- `lineApiBaseUrl`: Base URL Line API
- `twitterApiBaseUrl`: Base URL Twitter API
- `goongApiBaseUrl`: Base URL Goong API
- `firebaseStorageBaseUrl`: Base URL Firebase Storage
- `randomUserBaseUrl`: Base URL Random User API
- `resetPasswordLink`: Link reset password

### Path Constants
- `remoteConfigPath`: Đường dẫn remote config
- `settingsPath`: Đường dẫn settings

### Material App Constants
- `materialAppTitle`: Tiêu đề app
- `taskMenuMaterialAppColor`: Màu menu task (Colors.* enum values)

### Orientation Constants - DeviceOrientation enum values
**DeviceOrientation enum:** `portraitUp`, `landscapeLeft`, `portraitDown`, `landscapeRight`

- `mobileOrientation`: Array các orientation cho mobile
- `tabletOrientation`: Array các orientation cho tablet

### System UI Constants - SystemUiOverlayStyle properties

#### Cách điền giá trị:
1. **Simple mode**: `"light"` hoặc `"dark"` (sẽ tạo SystemUiOverlayStyle với Brightness tương ứng)
2. **Full SystemUiOverlayStyle**: 
   ```json
   "systemUiOverlay": "SystemUiOverlayStyle(
     statusBarColor: Colors.transparent,
     statusBarBrightness: Brightness.light,
     statusBarIconBrightness: Brightness.light,
     systemNavigationBarColor: Colors.transparent,
     systemNavigationBarIconBrightness: Brightness.light,
   )"
   ```

**Brightness enum values:** `light`, `dark`
**SystemUiOverlay enum values:** `top`, `bottom`

### FCM Constants
- `fcmImage`: Key cho FCM image
- `fcmConversationId`: Key cho FCM conversation ID

### API Config Constants
- `connectTimeout`: Timeout kết nối (seconds)
- `receiveTimeout`: Timeout nhận (seconds)
- `sendTimeout`: Timeout gửi (seconds)
- `maxRetries`: Số lần retry tối đa
- `firstRetryInterval`: Khoảng thời gian retry lần 1 (seconds)
- `secondRetryInterval`: Khoảng thời gian retry lần 2 (seconds)
- `thirdRetryInterval`: Khoảng thời gian retry lần 3 (seconds)

### Decoder Type Constants - enum values
**ErrorResponseDecoderType:** `jsonObject`, `jsonArray`, `line`
**SuccessResponseDecoderType:** `dataJsonObject`, `dataJsonArray`, `jsonObject`, `jsonArray`, `paging`, `plain`

- `defaultErrorResponseDecoderType`: Loại decoder mặc định cho error
- `defaultSuccessResponseDecoderType`: Loại decoder mặc định cho success

### Error Field Constants
- `nickname`: Field name cho nickname
- `email`: Field name cho email
- `password`: Field name cho password
- `passwordConfirmation`: Field name cho password confirmation

### Error Code Constants
- `invalidRefreshToken`: Mã lỗi refresh token không hợp lệ
- `invalidResetPasswordToken`: Mã lỗi reset password token không hợp lệ
- `multipleDeviceLogin`: Mã lỗi đăng nhập nhiều thiết bị
- `accountHasDeleted`: Mã lỗi tài khoản đã bị xóa
- `pageNotFound`: Mã lỗi trang không tìm thấy

### Error ID Constants
- `userNotFoundErrorId`: ID lỗi user không tìm thấy
- `refreshTokenFailedErrorId`: ID lỗi refresh token thất bại

### Header Constants
- `basicAuthorization`: Header Authorization
- `jwtAuthorization`: Header JWT-Authorization
- `userAgentKey`: Header User-Agent
- `bearer`: Prefix Bearer

### Response Constants
- `en`: Mã ngôn ngữ tiếng Anh
- `ja`: Mã ngôn ngữ tiếng Nhật
- `male`: Giá trị giới tính nam
- `female`: Giá trị giới tính nữ
- `other`: Giá trị giới tính khác
- `unknown`: Giá trị không xác định

### Log Event Constants
- `parameterSeparator`: Ký tự phân cách parameter
- `parameterMaxLength`: Độ dài tối đa parameter

## Environment Keys Configuration

### Các environment keys cho từng flavor:
- `develop`: Cấu hình cho môi trường develop
- `qa`: Cấu hình cho môi trường QA
- `staging`: Cấu hình cho môi trường staging
- `production`: Cấu hình cho môi trường production

Mỗi environment có các keys:
- `APP_BASIC_AUTH_NAME`: Tên user cho basic auth
- `APP_BASIC_AUTH_PASSWORD`: Password cho basic auth
- `APP_DOMAIN`: Domain API

## Project Configuration

### Android Configuration
- `versionName`: Tên phiên bản
- `versionCode`: Mã phiên bản
- `namespace`: Namespace Android
- `applicationIds`: Map các application ID cho từng flavor
- `appNames`: Map các tên app cho từng flavor

### iOS Configuration
- `bundleIds`: Map các bundle ID cho từng flavor
- `displayNames`: Map các tên hiển thị cho từng flavor

### Fastlane Configuration
- `slackWebhook`: Webhook URL cho Slack
- `issuerId`: Apple Issuer ID
- `firebaseToken`: Firebase token
- `mentions`: Mentions cho team
- `message`: Tin nhắn build
- `android.firebaseAppIds`: Map Firebase app ID cho Android
- `ios.teamId`: Apple Team ID
- `ios.keyId`: Apple Key ID
- `ios.keyFilepath`: Đường dẫn file key
- `ios.appStoreIds`: Map App Store ID cho từng flavor

### Lefthook Configuration
- `projectCode`: Mã dự án cho lefthook (ví dụ: "NFT")



## Workflow

### 1. Cấu hình dự án
1. Sửa file `README.input.md` với các giá trị dự án của bạn
2. Chạy lệnh build để cập nhật tất cả files:

```bash
# Cập nhật config và build dự án
make build_first_project

