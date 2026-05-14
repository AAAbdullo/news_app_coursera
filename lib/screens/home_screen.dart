import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../models/article.dart';
import '../services/news_service.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import 'detail_screen.dart';
import 'favorites_screen.dart';
import 'settings_menu_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _newsService = NewsService();
  final _storage = StorageService();
  final _searchController = TextEditingController();

  List<Article> _articles = [];
  List<Article> _favorites = [];
  bool _isLoading = true;
  String? _error;
  String _selectedCategory = 'general';
  int _currentIndex = 0;

  final List<String> _categories = [
    'general',
    'technology',
    'business',
    'science',
    'health',
    'sports'
  ];
  final List<String> _categoryLabels = [
    'Главное',
    'Технологии',
    'Бизнес',
    'Наука',
    'Здоровье',
    'Спорт'
  ];

  @override
  void initState() {
    super.initState();
    _loadNews();
    _loadFavorites();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNews() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final articles =
          await _newsService.getTopHeadlines(category: _selectedCategory);
      if (mounted) setState(() => _articles = articles);
    } catch (e) {
      if (mounted) {
        setState(() => _error =
            'Не удалось загрузить новости.\nПроверьте API ключ и интернет.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadFavorites() async {
    final favs = await _storage.getFavorites();
    if (mounted) setState(() => _favorites = favs);
  }

  Future<void> _toggleFavorite(Article article) async {
    final isFav = _favorites.any((a) => a.url == article.url);
    if (isFav) {
      await _storage.removeFavorite(article);
    } else {
      await _storage.addFavorite(article);
    }
    await _loadFavorites();
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('d MMM yyyy', 'ru').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  Widget _buildNewsTab() {
    return Column(
      children: [
        // Category chips
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _categories.length,
            itemBuilder: (_, i) {
              final selected = _categories[i] == _selectedCategory;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(_categoryLabels[i]),
                  selected: selected,
                  selectedColor: AppTheme.accent,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : null,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (_) {
                    setState(() => _selectedCategory = _categories[i]);
                    _loadNews();
                  },
                ),
              );
            },
          ),
        ),

        // News list
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.wifi_off,
                                size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(_error!,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey[600])),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: _loadNews,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Повторить'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadNews,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _articles.length,
                        itemBuilder: (_, i) => _buildArticleCard(_articles[i]),
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildArticleCard(Article article) {
    final isFav = _favorites.any((a) => a.url == article.url);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailScreen(article: article)),
      ).then((_) => _loadFavorites()),
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (article.urlToImage.isNotEmpty)
              CachedNetworkImage(
                imageUrl: article.urlToImage,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (_, __, ___) => Container(
                  height: 180,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported,
                      size: 48, color: Colors.grey),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Source & date
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          article.sourceName,
                          style: const TextStyle(
                            color: AppTheme.accent,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatDate(article.publishedAt),
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Title
                  Text(
                    article.title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold, height: 1.3),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Description
                  Text(
                    article.description,
                    style: TextStyle(
                        color: Colors.grey[600], fontSize: 13, height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Actions row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Читать далее →',
                        style: TextStyle(
                          color: AppTheme.accent,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _toggleFavorite(article),
                        icon: Icon(
                          isFav ? Icons.bookmark : Icons.bookmark_border,
                          color: isFav ? AppTheme.accent : Colors.grey,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.accent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.newspaper, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Text('NewsApp',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
        actions: [
          // Settings menu icon
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Настройки',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsMenuScreen()),
            ),
          ),
        ],
      ),
      body: _currentIndex == 0 ? _buildNewsTab() : const FavoritesScreen(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) {
          setState(() => _currentIndex = i);
          if (i == 1) _loadFavorites();
        },
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Новости'),
          NavigationDestination(
              icon: Icon(Icons.bookmark_outline),
              selectedIcon: Icon(Icons.bookmark),
              label: 'Избранное'),
        ],
      ),
    );
  }
}
