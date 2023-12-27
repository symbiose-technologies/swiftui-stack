
enum MatchedGeometryEffectIdentifiers {

  struct EdgeTrailing: Hashable {

    public enum Content: Hashable {
      case root
      case stacked(_StackedViewIdentifier)
    }

    let content: Content

  }
    
  struct EdgeBottom: Hashable {

    public enum Content: Hashable {
      case root
      case stacked(_StackedViewIdentifier)
    }

    let content: Content

  }

}
