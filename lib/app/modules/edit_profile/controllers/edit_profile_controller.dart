import 'package:get/get.dart';
import 'package:mobile/app/data/models/user.dart';
import 'package:mobile/app/data/services/auth_services.dart';

class EditProfileController extends GetxController {
  final user = UserModel(
    name: '',
    profileImage: '',
    level: 0,
    history: [],
    email: '',
    points: 0,
    authType: '',
  ).obs;

  final isLoading = false.obs;
  final AuthService _authService = AuthService();

  @override
  void onInit() {
    super.onInit();
    fetchUser();
  }

  Future<void> fetchUser() async {
    isLoading.value = true;
    try {
      final result = await _authService.fetchUserProfile();
      if (result != null && result.containsKey('user')) {
        user.value = UserModel.fromMap(result['user']);
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal mengambil data profil: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateUser(String name, String email, String imageUrl,
      {String? password, String? confirmPassword}) async {
    try {
      await _authService.editUser(
        name: name,
        email: email,
        profileImage: imageUrl,
        password: password,
        confirmPassword: confirmPassword,
      );

      user.update((val) {
        if (val != null) {
          val.name = name;
          val.email = email;
          val.profileImage = imageUrl;
        }
      });

      Get.snackbar("Sukses", "Profil berhasil diperbarui");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }
}
