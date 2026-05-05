class DaoException implements Exception {
  final String message;

  const DaoException(this.message);

  @override
  String toString() => message;
}

class CajaSesionNoActivaException extends DaoException {
  const CajaSesionNoActivaException(String message) : super(message);
}

class StockInsuficienteException extends DaoException {
  const StockInsuficienteException(String message) : super(message);
}

class ContextoInvalidoException extends DaoException {
  const ContextoInvalidoException(String message) : super(message);
}

class WarehouseNotFoundException extends DaoException {
  const WarehouseNotFoundException(String message) : super(message);
}

class InvalidTransferException extends DaoException {
  const InvalidTransferException(String message) : super(message);
}
