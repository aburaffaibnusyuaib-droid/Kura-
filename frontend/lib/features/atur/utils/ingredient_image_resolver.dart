/// Helper dinamis penghasil URL foto bahan makanan beresolusi tinggi berbasis kata kunci pencarian.
class IngredientImageResolver {
  IngredientImageResolver._();

  /// Menghasilkan URL gambar stabil berbasis kata kunci deskriptif bahan makanan
  static String getSearchUrl(String keyword) {
    final cleanKeyword = Uri.encodeComponent(
      keyword.toLowerCase().trim().replaceAll(RegExp(r'\s+'), '-'),
    );
    return 'https://source.unsplash.com/featured/600x600/?$cleanKeyword';
  }
}
