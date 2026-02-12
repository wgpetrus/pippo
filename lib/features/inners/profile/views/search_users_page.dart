import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/responsive_utils.dart';
import '../../../../shared/widgets/app_appbar.dart';
import '../controllers/profile_search_controller.dart';
import '../widgets/user_search_item.dart';

/// Página de busca de usuários
class SearchUsersPage extends StatefulWidget {
  const SearchUsersPage({super.key});

  @override
  State<SearchUsersPage> createState() => _SearchUsersPageState();
}

class _SearchUsersPageState extends State<SearchUsersPage> {
  late final ProfileSearchController _controller;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ProfileSearchController>();
    _controller.clearSearch();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveUtils(context);

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppAppbar(title: 'profile_search_title'.tr),
      body: Column(
        children: [
          // Campo de busca
          Padding(
            padding: EdgeInsets.all(r.spacing16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'profile_search_hint'.tr,
                hintStyle: AppTheme.textMd.copyWith(color: AppTheme.gray400),
                prefixIcon: const Icon(
                  FontAwesomeIcons.magnifyingGlass,
                  color: AppTheme.gray400,
                  size: 18,
                ),
                suffixIcon: Obx(() {
                  if (_controller.searchQuery.value.isEmpty) return const SizedBox();
                  return IconButton(
                    icon: const Icon(Icons.clear, color: AppTheme.gray400),
                    onPressed: () {
                      _searchController.clear();
                      _controller.clearSearch();
                    },
                  );
                }),
                filled: true,
                fillColor: AppTheme.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.gray300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.gray300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: r.spacing16,
                  vertical: r.spacing12,
                ),
              ),
              onChanged: (value) {
                // Debounce de 500ms
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (_searchController.text == value) {
                    _controller.searchUsers(value);
                  }
                });
              },
            ),
          ),

          // Resultados
          Expanded(
            child: Obx(() {
              // Loading
              if (_controller.isSearching.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppTheme.primary),
                );
              }

              // Estado inicial (sem busca)
              if (_controller.searchQuery.value.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FontAwesomeIcons.magnifyingGlass,
                        size: 64,
                        color: AppTheme.gray300,
                      ),
                      SizedBox(height: r.spacing16),
                      Text(
                        'profile_search_empty_state'.tr,
                        style: AppTheme.textMd.copyWith(
                          color: AppTheme.gray400,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Erro
              if (_controller.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(r.spacing16),
                    child: Text(
                      _controller.errorMessage.value,
                      style: AppTheme.textMd.copyWith(
                        color: _controller.searchResults.isEmpty
                            ? AppTheme.gray600
                            : AppTheme.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              // Resultados
              if (_controller.searchResults.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FontAwesomeIcons.userSlash,
                        size: 64,
                        color: AppTheme.gray300,
                      ),
                      SizedBox(height: r.spacing16),
                      Text(
                        'profile_search_no_results'.tr,
                        style: AppTheme.textMd.copyWith(
                          color: AppTheme.gray600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                itemCount: _controller.searchResults.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: AppTheme.gray200,
                  indent: r.spacing16 + 48 + r.spacing12,
                ),
                itemBuilder: (context, index) {
                  final user = _controller.searchResults[index];
                  return UserSearchItem(
                    userId: user['userId'] ?? '',
                    name: user['name'] ?? '',
                    username: user['username'] ?? '',
                    avatarId: user['avatarId'] ?? 'avatar_01',
                    country: user['country'],
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
