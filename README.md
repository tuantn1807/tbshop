# TLShop

## Mô tả chung

**TLShop** là ứng dụng thương mại điện tử đa nền tảng được xây dựng bằng **Flutter** và **Firebase**, được thiết kế theo **kiến trúc MVVM**. Ứng dụng tích hợp **Trí tuệ nhân tạo (AI)** để nâng cao trải nghiệm người dùng thông qua các gợi ý sản phẩm cá nhân hóa, dự báo nhu cầu và hỗ trợ khách hàng bằng chatbot.

## Tính năng:
### Admin
- Đăng nhập, đăng xuất
- Quản lý danh mục sản phẩm (xem, thêm, sửa, xóa)
- Quản lý sản phẩm (xem, thêm, sửa, xóa)
- Xem đánh giá chi tiết về sản phẩm
- Quản lý đơn hàng của khách hàng

### User:
- Đăng ký, đăng nhập, đăng xuất
- Xem danh mục sản phẩm
- Tìm kiếm sản phẩm
- Xem thông tin chi tiết sản phẩm
- Xem các sản phẩm được giảm giá trên 10%
- Gửi đánh giá sản phẩm
- Xem, sửa, xóa đánh giá sản phẩm đã gửi
- Đặt hàng và theo dõi đơn hàng
- Xem lịch sử đơn hàng
- Hỗ trợ qua chatbot
- Nhận gợi ý sản phẩm thông qua AI

## Công nghệ sử dụng

### Giao diện người dùng (UI/Frontend)
- Flutter, Dart

### Backend
- Firebase Realtime Database

### Lưu trữ
- Firebase Storage

### Trí tuệ nhân tạo (AI)
- Rasa (cho chatbot)
- Hệ thống gợi ý tùy chỉnh:
    - Dữ liệu: Đánh giá, Click, Giỏ hàng
    - Kết hợp phương pháp lọc dựa trên nội dung và lọc cộng tác
    - Dự báo nhu cầu: Dự đoán nhu cầu mua sắm trong tương lai để hỗ trợ quản lý kho hàng và đưa ra gợi ý cá nhân hóa
### Kiến trúc
- MVVM (Model-View-ViewModel) nhằm tăng khả năng mở rộng và phân tách các thành phần
## Cài đặt và chạy ứng dụng
### Yêu cầu hệ thống
- Flutter SDK
- Dart
- Firebase account
### Các bước cài đặt
1. Clone repository:
   ```
   git clone https://github.com/tuantuan1807/tlshop
   ```
2. Di chuyển vào thư mục dự án:
   ```
   cd tlshop
   ```
3. Cài đặt các dependencies:
   ```
   flutter pub get
   ```
4. Kết nối với Firebase:
    Link firebase: https://book-app-a2432-default-rtdb.firebaseio.com/

5. Chạy ứng dụng:
   ```
   flutter run
   ```
6. Chạy chatbot:
   Mở 2 terminal, terminal 1 chạy:
    ```
   cd rasa_chatbot
    ```
    ```
   python -m venv my_env (chỉ chạy lần đầu)
    ```
   ```
   my_env\Scripts\activate
    ```
   ```
   pip install rasa**(chỉ chạy lần đầu)**
    ```
    ```
   rasa run actions
    ```
   terminal 2 chạy:
    ```
   cd rasa_chatbot
    ```
    ```
   my_env\Scripts\activate
    ```
    ```
   rasa run --enable-api --cors "*" --port 5005 --debug
### Tài khoản demo
- **Admin**: 030041975 / password: 123456789
- **User**: 0911103884 / password: 18072004