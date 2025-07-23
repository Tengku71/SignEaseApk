import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/app/routes/app_pages.dart';
import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'SignEase',
          style: GoogleFonts.lobster(
            textStyle: const TextStyle(fontSize: 20, color: Colors.orange),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Text(
                'Register',
                style: GoogleFonts.lobster(
                  textStyle:
                      const TextStyle(fontSize: 40, color: Colors.orange),
                ),
              ),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Nama',
                    style: TextStyle(fontSize: 20, color: Colors.orange)),
              ),
              const SizedBox(height: 10),
              TextField(
                onChanged: (value) => controller.name.value = value,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20)),
                  labelText: 'Nama',
                  hintText: 'Masukkan nama Anda',
                ),
              ),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('TTL',
                    style: TextStyle(fontSize: 20, color: Colors.orange)),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 150,
                    child: Obx(
                      () => TextField(
                        decoration: InputDecoration(
                          labelText: 'Tanggal Lahir',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20)),
                          hintText: controller.birthDate.value == null
                              ? 'Pilih tanggal'
                              : controller.birthDate.value!
                                  .toLocal()
                                  .toString()
                                  .split(' ')[0],
                        ),
                        readOnly: true,
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null) {
                            controller.birthDate.value = pickedDate;
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 150,
                    child: Obx(
                      () => TextField(
                        decoration: InputDecoration(
                          labelText: 'Jenis Kelamin',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20)),
                          hintText: controller.gender.value.isEmpty
                              ? 'Pilih jenis kelamin'
                              : controller.gender.value,
                        ),
                        readOnly: true,
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return SizedBox(
                                height: 150,
                                child: Column(
                                  children: [
                                    ListTile(
                                      title: const Text('Laki-laki'),
                                      onTap: () {
                                        controller.gender.value = 'Laki-laki';
                                        Navigator.pop(context);
                                      },
                                    ),
                                    ListTile(
                                      title: const Text('Perempuan'),
                                      onTap: () {
                                        controller.gender.value = 'Perempuan';
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Email',
                    style: TextStyle(fontSize: 20, color: Colors.orange)),
              ),
              const SizedBox(height: 10),
              TextField(
                onChanged: (value) => controller.email.value = value,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20)),
                  labelText: 'Email',
                  hintText: 'Masukkan email Anda',
                ),
              ),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Alamat',
                    style: TextStyle(fontSize: 20, color: Colors.orange)),
              ),
              const SizedBox(height: 10),
              TextField(
                onChanged: (value) => controller.address.value = value,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20)),
                  labelText: 'Alamat',
                  hintText: 'Masukkan alamat Anda',
                ),
              ),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Password',
                    style: TextStyle(fontSize: 20, color: Colors.orange)),
              ),
              const SizedBox(height: 10),
              TextField(
                onChanged: (value) => controller.password.value = value,
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20)),
                  labelText: 'Password',
                  hintText: 'Masukkan password Anda',
                ),
              ),
              const SizedBox(height: 30),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Konfirmasi Password',
                    style: TextStyle(fontSize: 20, color: Colors.orange)),
              ),
              const SizedBox(height: 10),
              TextField(
                onChanged: controller.updateConfirmPassword,
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20)),
                  labelText: 'Konfirmasi Password',
                  hintText: 'Ulangi password Anda',
                ),
              ),
              const SizedBox(height: 20),
              Obx(() {
                return ElevatedButton(
                  onPressed:
                      controller.isLoading.value ? null : controller.register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 20),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Daftar',
                          style: TextStyle(color: Colors.white)),
                );
              }),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => Get.toNamed(Routes.LOGIN),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('sudah punya akun? '),
                    Text(
                      'masuk',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SizedBox(
                      width: 138,
                      child: Divider(color: Colors.black, thickness: 2)),
                  SizedBox(width: 20),
                  Text('OR'),
                  SizedBox(width: 20),
                  SizedBox(
                      width: 120,
                      child: Divider(color: Colors.black, thickness: 2)),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () =>
                    Get.snackbar('Info', 'Google Sign-In belum diimplementasi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/google.png', width: 30, height: 30),
                    const SizedBox(width: 10),
                    const Text(
                      'Daftar menggunakan Google',
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
