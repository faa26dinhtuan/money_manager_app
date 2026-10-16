import 'package:flutter/material.dart';
import 'package:money_manager_app/core/widgets/category_icon.dart';
import 'package:money_manager_app/core/widgets/settings_button.dart';
import 'package:money_manager_app/core/widgets/type_tabs.dart';
import 'package:money_manager_app/data/models/category.dart';
import 'package:money_manager_app/data/services/app_store.dart';
import 'package:money_manager_app/features/categories/create_category_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _store = AppStore.instance;
  TxType _type = TxType.expense;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) {
        final categories = _store.categoriesOf(_type);
        return Scaffold(
          appBar: AppBar(
            title: const Text('Danh mục'),
            actions: const [SettingsButton()],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TypeTabs(
                  type: _type,
                  onChanged: (t) => setState(() => _type = t),
                ),
              ),
            ),
          ),
          body: GridView.count(
            crossAxisCount: 4,
            padding: const EdgeInsets.all(20),
            mainAxisSpacing: 20,
            crossAxisSpacing: 8,
            childAspectRatio: 0.85,
            children: [
              for (final c in categories)
                _CategoryTile(
                  category: c,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CreateCategoryScreen(category: c),
                    ),
                  ),
                ),
              _AddTile(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CreateCategoryScreen(initialType: _type),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, required this.onTap});
  final Category category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          CategoryIcon(icon: category.icon, color: category.color, size: 56),
          const SizedBox(height: 6),
          Text(
            category.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black26, width: 1.5),
            ),
            child: const Icon(Icons.add, color: Colors.black45),
          ),
          const SizedBox(height: 6),
          const Text('Thêm', style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
