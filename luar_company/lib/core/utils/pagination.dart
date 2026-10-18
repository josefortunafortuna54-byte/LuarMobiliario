/// Paginação por "registo extra": os repositórios pedem `pageSize + 1`
/// linhas — as `pageSize` a apresentar mais uma que só serve para saber se
/// existem mais resultados. Evita o falso positivo de `length == pageSize`
/// no último lote (a página devolvida era exatamente cheia e o `hasMore`
/// ficava `true` sem haver mais dados).
class PageSlice<T> {
  const PageSlice(this.items, this.hasMore);

  /// Itens a apresentar (no máximo `pageSize`).
  final List<T> items;

  /// `true` se o backend devolveu o registo extra (há mais páginas).
  final bool hasMore;
}

PageSlice<T> slicePage<T>(List<T> fetched, int pageSize) {
  if (fetched.length > pageSize) {
    return PageSlice(fetched.sublist(0, pageSize), true);
  }
  return PageSlice(fetched, false);
}
