import 'package:flutter/material.dart';

import 'database_helper.dart';
import 'notification_service.dart';

// =================================================================
// 2. APLICACIÓN PRINCIPAL
// =================================================================
void main() {
  runApp(const MiSintromApp());
}

class MiSintromApp extends StatelessWidget {
  const MiSintromApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi Sintrom',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        useMaterial3: true,
      ),
      home: const PantallaPrincipal(),
    );
  }
}

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  int _indiceActual = 0;

  final List<Widget> _pantallas = <Widget>[
    const VistaInicio(),
    const VistaCalendario(),
    const VistaInformes(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mi Sintrom v1.0',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        elevation: 2,
      ),
      body: _pantallas[_indiceActual],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceActual,
        onTap: (int index) {
          setState(() {
            _indiceActual = index;
          });
        },
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_rounded),
            label: 'Calendario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_rounded),
            label: 'Informes',
          ),
        ],
      ),
    );
  }
}

// =================================================================
// 3. PANTALLA: VISTA INICIO
// =================================================================
class VistaInicio extends StatefulWidget {
  const VistaInicio({super.key});

  @override
  State<VistaInicio> createState() => _VistaInicioState();
}

class _VistaInicioState extends State<VistaInicio> {
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _notificationService.initNotification();
  }

  double _dosisHoy = 0.75;
  bool _tomado = false;
  String _horaToma = "--:--";

  final double _ultimoINR = 2.4;
  final String _proximoControl = "26/06/2026";

  void _marcarToma() {
    setState(() {
      _tomado = !_tomado;
      if (_tomado) {
        final DateTime ahora = DateTime.now();
        _horaToma =
            "${ahora.hour.toString().padLeft(2, '0')}:${ahora.minute.toString().padLeft(2, '0')}";
      } else {
        _horaToma = "--:--";
      }
    });
  }

  Widget _dibujarPastilla(double dosis) {
    final int cuartosActivos = (dosis / 0.25).round();

    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.teal.shade700, width: 3),
        color: Colors.white,
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(70),
        child: GridView.count(
          crossAxisCount: 2,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
          children: List<Widget>.generate(4, (int index) {
            final bool activo = index < cuartosActivos;
            return Container(
              color: activo
                  ? (_tomado ? Colors.teal.shade400 : Colors.amber.shade400)
                  : Colors.grey.shade200,
              child: Center(
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white24,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Hoy es ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 12),

          // --- Tarjeta dosis ---
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: <Color>[
                    Colors.white,
                    Colors.teal.shade50.withValues(alpha: 0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                children: [
                  const Text(
                    "DOSIS RECOMENDADA",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _dibujarPastilla(_dosisHoy),
                  const SizedBox(height: 20),
                  Text(
                    _dosisHoy == 0.0 ? "0 mg (Descanso)" : "$_dosisHoy mg",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Colors.teal.shade900,
                    ),
                  ),
                  Text(
                    _dosisHoy == 0.25
                        ? "1/4 de comprimido"
                        : _dosisHoy == 0.50
                        ? "1/2 comprimido"
                        : _dosisHoy == 0.75
                        ? "3/4 de comprimido"
                        : _dosisHoy == 1.00
                        ? "1 comprimido entero"
                        : "Pauta personalizada",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Divider(),
                  ),

                  // Botón marcar toma
                  ElevatedButton.icon(
                    onPressed: _marcarToma,
                    icon: Icon(
                      _tomado
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      size: 28,
                    ),
                    label: Text(
                      _tomado
                          ? "TOMADO A LAS $_horaToma"
                          : "MARCAR COMO TOMADO",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: _tomado
                          ? Colors.teal.shade600
                          : Colors.amber.shade600,
                      minimumSize: const Size.fromHeight(54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 3,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Botón prueba notificación
                  ElevatedButton.icon(
                    onPressed: () {
                      _notificationService.showNotification(
                        title: "Prueba de Sintrom",
                        body: "¡La alarma funciona correctamente!",
                      );
                    },
                    icon: const Icon(Icons.notifications_active),
                    label: const Text("Probar Notificación"),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.teal.shade300,
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // --- Tarjetas INR y próximo control ---
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 150,
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.bloodtype,
                            color: Colors.redAccent,
                            size: 28,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Último INR",
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "$_ultimoINR",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 150,
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Colors.teal,
                            size: 28,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Próximo Control",
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _proximoControl,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.teal.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // --- Chips para cambiar dosis (modo prueba) ---
          Card(
            color: Colors.grey.shade100,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 12.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text(
                    "Probar:",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  ChoiceChip(
                    label: const Text("0.25"),
                    selected: _dosisHoy == 0.25,
                    onSelected: (bool selected) {
                      if (selected) setState(() => _dosisHoy = 0.25);
                    },
                  ),
                  ChoiceChip(
                    label: const Text("0.50"),
                    selected: _dosisHoy == 0.50,
                    onSelected: (bool selected) {
                      if (selected) setState(() => _dosisHoy = 0.50);
                    },
                  ),
                  ChoiceChip(
                    label: const Text("0.75"),
                    selected: _dosisHoy == 0.75,
                    onSelected: (bool selected) {
                      if (selected) setState(() => _dosisHoy = 0.75);
                    },
                  ),
                  ChoiceChip(
                    label: const Text("1.00"),
                    selected: _dosisHoy == 1.00,
                    onSelected: (bool selected) {
                      if (selected) setState(() => _dosisHoy = 1.00);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// 4. PANTALLA: VISTA CALENDARIO
// =================================================================
class VistaCalendario extends StatelessWidget {
  const VistaCalendario({super.key});

  double _obtenerDosisSemanas(int dia) {
    int diaSemana = (dia - 1) % 7;
    if (diaSemana == 6) return 0.0;
    if (diaSemana == 1 || diaSemana == 3) return 0.75;
    return 0.50;
  }

  Widget _dibujarPastillaMini(double dosis) {
    final int cuartosActivos = (dosis / 0.25).round();
    if (cuartosActivos == 0) {
      return const Icon(Icons.blur_on_rounded, size: 20, color: Colors.grey);
    }

    return SizedBox(
      width: 22,
      height: 22,
      child: GridView.count(
        crossAxisCount: 2,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
        children: List<Widget>.generate(4, (int index) {
          return Container(
            decoration: BoxDecoration(
              color: index < cuartosActivos
                  ? Colors.teal.shade400
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const List<String> diasSemana = <String>['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    const int totalDiasJunio = 30;

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Preparando escáner de IA...'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade800,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
                icon: const Icon(Icons.auto_awesome),
                label: const Text(
                  'Escanear hoja de Sintrom con IA',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Card(
              color: Colors.teal.shade700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14.0),
                child: Text(
                  'JUNIO 2026',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: diasSemana
                  .map(
                    (String dia) => Text(
                      dia,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 8),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: totalDiasJunio,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.78,
              ),
              itemBuilder: (BuildContext context, int index) {
                final int dia = index + 1;
                final double dosis = _obtenerDosisSemanas(dia);
                final bool esDiaControl = (dia == 26);

                return Container(
                  decoration: BoxDecoration(
                    color: esDiaControl ? Colors.red.shade50 : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: esDiaControl
                          ? Colors.redAccent
                          : Colors.grey.shade200,
                      width: esDiaControl ? 2 : 1,
                    ),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 3,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        '$dia',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: esDiaControl
                              ? Colors.red.shade900
                              : Colors.black87,
                        ),
                      ),
                      _dibujarPastillaMini(dosis),
                      esDiaControl
                          ? const Icon(
                              Icons.bloodtype,
                              color: Colors.redAccent,
                              size: 16,
                            )
                          : Text(
                              dosis == 0.0 ? 'Desc.' : dosis.toStringAsFixed(2),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: dosis == 0.0
                                    ? Colors.grey
                                    : Colors.teal.shade900,
                              ),
                            ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            Card(
              color: Colors.grey.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.teal.shade400,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Dosis Activa',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                    const Row(
                      children: [
                        Icon(
                          Icons.blur_on_rounded,
                          size: 16,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Día Descanso',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                    const Row(
                      children: [
                        Icon(
                          Icons.bloodtype,
                          color: Colors.redAccent,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Control INR',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =================================================================
// 5. PANTALLA: VISTA INFORMES
// =================================================================
class VistaInformes extends StatefulWidget {
  const VistaInformes({super.key});

  @override
  State<VistaInformes> createState() => _VistaInformesState();
}

class _VistaInformesState extends State<VistaInformes> {
  final TextEditingController _inrController = TextEditingController();
  final TextEditingController _dosisController = TextEditingController();

  void _refrescarLista() {
    setState(() {});
  }

  @override
  void dispose() {
    _inrController.dispose();
    _dosisController.dispose();
    super.dispose();
  }

  void _mostrarDialogoInsertar() {
    _inrController.clear();
    _dosisController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Insertar Informe',
            style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _inrController,
                decoration: const InputDecoration(
                  labelText: 'Valor del INR (ej. 2.5)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _dosisController,
                decoration: const InputDecoration(
                  labelText: 'Dosis diaria (ej. 1.25 comp.)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              onPressed: () async {
                final double? inr = double.tryParse(
                  _inrController.text.replaceAll(',', '.'),
                );
                final double? dosis = double.tryParse(
                  _dosisController.text.replaceAll(',', '.'),
                );

                if (inr != null && dosis != null) {
                  final DateTime now = DateTime.now();
                  final String fechaHoy =
                      "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";

                  final nuevoRegistro = {
                    'inr': inr,
                    'dosis': dosis,
                    'fecha': fechaHoy,
                  };

                  await DatabaseHelper.instance.insertarControl(nuevoRegistro);
                  if (context.mounted) {
                    Navigator.pop(context);
                    _refrescarLista();
                  }
                }
              },
              child: const Text(
                'Guardar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Historial de Controles',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.add_circle,
                  color: Colors.teal,
                  size: 36,
                ),
                onPressed: _mostrarDialogoInsertar,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: DatabaseHelper.instance.getHistorialControles(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'Aún no hay controles registrados.\nPulsa el botón superior + para insertar uno.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }

                final listaControles = snapshot.data!;

                return ListView.builder(
                  itemCount: listaControles.length,
                  itemBuilder: (context, index) {
                    final registro =
                        listaControles[listaControles.length - 1 - index];

                    final double inr =
                        (registro['inr'] as num?)?.toDouble() ?? 0.0;
                    final double dosis =
                        (registro['dosis'] as num?)?.toDouble() ?? 0.0;
                    final String fecha =
                        registro['fecha']?.toString() ?? 'Sin fecha';

                    String estado = 'En rango';
                    Color colorEstado = Colors.green;

                    if (inr > 3.0) {
                      estado = 'Alto';
                      colorEstado = Colors.red;
                    } else if (inr < 2.0) {
                      estado = 'Bajo';
                      colorEstado = Colors.orange;
                    }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: colorEstado.withValues(alpha: 0.15),
                          radius: 25,
                          child: Text(
                            inr.toStringAsFixed(1),
                            style: TextStyle(
                              color: colorEstado,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        title: Text(
                          'Control: $fecha',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          'Dosis diaria: ${dosis.toStringAsFixed(2)} comp.',
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colorEstado.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            estado,
                            style: TextStyle(
                              color: colorEstado,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

extension SafeNum on num? {
  num withDefault(num defaultValue) => this ?? defaultValue;
}
