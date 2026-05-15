class DaoException implements Exception {
  final String message;

  const DaoException(this.message);

  @override
  String toString() => message;
}

class CajaSesionNoActivaException extends DaoException {
  const CajaSesionNoActivaException(super.message);
}

class StockInsuficienteException extends DaoException {
  const StockInsuficienteException(super.message);
}

class ContextoInvalidoException extends DaoException {
  const ContextoInvalidoException(super.message);
}

class WarehouseNotFoundException extends DaoException {
  const WarehouseNotFoundException(super.message);
}

class InvalidTransferException extends DaoException {
  const InvalidTransferException(super.message);
}
