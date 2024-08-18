class CacheObject<T extends Object?> {
  late T _object;
  CacheObject({
    required T object,
    void Function(T object)? close,
  }) : _object = object;
  set set(T object) => this._object = object;
  T get get => this._object;
}
