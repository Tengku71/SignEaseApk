import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/modules/edit_profile/controllers/edit_profile_controller.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final imageController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profil')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = controller.user.value;

        nameController.text = user.name;
        emailController.text = user.email;
        imageController.text = user.profileImage;

        final isGoogleAuth = user.authType?.toLowerCase() == 'google';

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Nama", style: TextStyle(fontSize: 16)),
              TextField(controller: nameController),
              const SizedBox(height: 16),
              const Text("Email", style: TextStyle(fontSize: 16)),
              TextField(
                controller: emailController,
                enabled: false,
                decoration: InputDecoration(
                  hintText: "Email",
                  helperText: isGoogleAuth
                      ? "Email tidak dapat diubah (akun Google)"
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              // const Text("URL Foto Profil", style: TextStyle(fontSize: 16)),
              // TextField(controller: imageController),
              const SizedBox(height: 16),
              const Text("Password (opsional)", style: TextStyle(fontSize: 16)),
              TextField(
                controller: passwordController,
                obscureText: true,
                enabled: !isGoogleAuth,
                decoration: InputDecoration(
                  hintText: "Password baru",
                  helperText: isGoogleAuth
                      ? "Password tidak dapat diubah (akun Google)"
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              const Text("Konfirmasi Password", style: TextStyle(fontSize: 16)),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                enabled: !isGoogleAuth,
                decoration: InputDecoration(
                  hintText: "Ulangi password",
                  helperText: isGoogleAuth
                      ? "Password tidak dapat diubah (akun Google)"
                      : null,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text("Simpan"),
                  onPressed: () {
                    controller.updateUser(
                      nameController.text.trim(),
                      emailController.text.trim(),
                      imageController.text.trim(),
                      password: passwordController.text.trim().isEmpty
                          ? null
                          : passwordController.text.trim(),
                      confirmPassword:
                          confirmPasswordController.text.trim().isEmpty
                              ? null
                              : confirmPasswordController.text.trim(),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
