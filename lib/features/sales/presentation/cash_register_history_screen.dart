import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Asumiendo que usas GoRouter
import 'package:intl/intl.dart';

class CashRegisterHistoryScreen extends StatelessWidget {
  const CashRegisterHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ESTADO MOCK (Simular si hay una caja abierta actualmente)
    // En producción: bool isOpen = ref.watch(cashRegisterProvider).isOpen;
    const bool isSessionActive = true;

    // DATOS MOCK: Historial de cierres anteriores
    final List<Map<String, dynamic>> closedSessions = [
      {
        'id': '105',
        'closeDate': DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        'openDate': DateTime.now().subtract(const Duration(days: 1, hours: 10)),
        'totalCash': 5450.00,
        'difference': 0.0, // Cuadre perfecto
        'user': 'Juan Pérez',
      },
      {
        'id': '104',
        'closeDate': DateTime.now().subtract(const Duration(days: 2, hours: 1)),
        'openDate': DateTime.now().subtract(const Duration(days: 2, hours: 9)),
        'totalCash': 4200.50,
        'difference': -50.0, // Faltante
        'user': 'Maria Lopez',
      },
      {
        'id': '103',
        'closeDate': DateTime.now().subtract(const Duration(days: 3, hours: 3)),
        'openDate': DateTime.now().subtract(const Duration(days: 3, hours: 12)),
        'totalCash': 6100.00,
        'difference': 20.0, // Sobrante
        'user': 'Juan Pérez',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Historial de Cajas",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. TARJETA DE ESTADO ACTUAL (ACCESO RÁPIDO)
            const Text(
              "Estado Actual",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            _CurrentSessionCard(isActive: isSessionActive),

            const SizedBox(height: 30),

            // 2. LISTA DE CIERRES ANTERIORES
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Cierres Anteriores",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                IconButton(
                  onPressed: () {}, // Filtro por fecha
                  icon: const Icon(
                    Icons.calendar_month_outlined,
                    color: Colors.blueGrey,
                  ),
                  tooltip: "Filtrar por fecha",
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (closedSessions.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("No hay historial registrado"),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: closedSessions.length,
                itemBuilder: (context, index) {
                  final session = closedSessions[index];
                  return _ClosedSessionItem(session: session);
                },
              ),
          ],
        ),
      ),
    );
  }
}

// --- WIDGET: TARJETA DE ACCIÓN PRINCIPAL ---
class _CurrentSessionCard extends StatelessWidget {
  final bool isActive;

  const _CurrentSessionCard({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? Colors.green.shade200 : Colors.blue.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isActive
                ? Colors.green.withOpacity(0.05)
                : Colors.blue.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icono Grande
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isActive ? Colors.green.shade50 : Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isActive ? Icons.storefront : Icons.storefront_outlined,
              color: isActive ? Colors.green.shade700 : Colors.blue.shade700,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),

          // Textos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isActive ? "Turno Activo" : "Caja Cerrada",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isActive
                      ? "La caja está abierta y registrando."
                      : "No hay turno activo actualmente.",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),

          // Botón de Acción
          ElevatedButton(
            onPressed: () {
              // NAVEGACIÓN A LA VISTA OPERATIVA
              context.push(
                '/cash-register',
              ); // Esta es la ruta a la pantalla CashRegisterScreen que hicimos antes
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isActive
                  ? Colors.green.shade700
                  : Colors.blue.shade800,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: Text(isActive ? "IR A CAJA" : "ABRIR"),
          ),
        ],
      ),
    );
  }
}

// --- WIDGET: ITEM DE HISTORIAL ---
class _ClosedSessionItem extends StatelessWidget {
  final Map<String, dynamic> session;

  const _ClosedSessionItem({required this.session});

  @override
  Widget build(BuildContext context) {
    final double diff = session['difference'];
    Color diffColor = Colors.grey;
    IconData diffIcon = Icons.check_circle_outline;

    if (diff > 0) {
      diffColor = Colors.blue; // Sobrante
      diffIcon = Icons.arrow_upward;
    } else if (diff < 0) {
      diffColor = Colors.red; // Faltante
      diffIcon = Icons.warning_amber_rounded;
    } else {
      diffColor = Colors.green; // Cuadre
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () {
          context.push(
            '/cash-register-detail',
            extra: session['id'], // Pasas el ID como argumento
          );
        },
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('dd').format(session['closeDate']),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            Text(
              DateFormat('MMM').format(session['closeDate']).toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        title: Text(
          NumberFormat.simpleCurrency().format(session['totalCash']),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              "Cierre: ${DateFormat('hh:mm a').format(session['closeDate'])} • ${session['user']}",
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: diffColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(diffIcon, color: diffColor, size: 20),
        ),
      ),
    );
  }
}
