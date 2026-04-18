import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/providers/bike_provider.dart';
import '../../core/providers/sound_provider.dart';
import '../../data/models/sound_test_model.dart';

enum SoundCheckMode { normal, rev }

class SoundMeasureScreen extends StatefulWidget {
  const SoundMeasureScreen({super.key});

  @override
  State<SoundMeasureScreen> createState() => _SoundMeasureScreenState();
}

class _SoundMeasureScreenState extends State<SoundMeasureScreen> with TickerProviderStateMixin {
  SoundCheckMode _currentMode = SoundCheckMode.normal;
  double _decibels = 0.0;
  double _peakDb = 0.0;
  double _avgDb = 0.0;
  int _measureCount = 0;
  double _totalDb = 0.0;
  
  bool _isMeasuring = false;
  bool _isAnalyzing = false;
  NoiseMeter? _noiseMeter;
  StreamSubscription<NoiseReading>? _noiseSubscription;
  
  // Rev Mode State
  int _currentStep = 0; // 0: Idle, 1: Mid, 2: Peak
  final Map<int, double> _stepResults = {};

  Bike? _selectedBike;
  
  // Animations
  late AnimationController _meterController;
  late Animation<double> _meterAnimation;
  late AnimationController _pulseController;
  late AnimationController _headerController;

  @override
  void initState() {
    super.initState();
    _noiseMeter = NoiseMeter();
    
    _meterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _meterAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _meterController, curve: Curves.easeOutCubic),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  double get _currentLimit {
    if (_selectedBike == null) return 95.0;
    if (_selectedBike!.isScooter) return 85.0;
    if (_selectedBike!.name.contains('Duke 390') || _selectedBike!.name.contains('RC 390')) return 92.0;
    if (_selectedBike!.name.contains('Classic 350')) return 90.0;
    if (_selectedBike!.name.contains('S1000RR') || _selectedBike!.name.contains('Panigale')) return 98.0;
    return 95.0;
  }

  Future<bool> _checkPermission() async {
    if (!await Permission.microphone.isGranted) {
      PermissionStatus status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  void _toggleMeasurement() async {
    if (_isMeasuring) {
      _stopMeasurement();
    } else {
      ScaffoldMessenger.of(context).clearSnackBars();
      if (_selectedBike == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a bike first'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _showBikePicker();
        return;
      }
      
      if (await _checkPermission()) {
        _startMeasurement();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Microphone permission is required')),
          );
        }
      }
    }
  }

  void _reset() {
    setState(() {
      _decibels = 0.0;
      _peakDb = 0.0;
      _avgDb = 0.0;
      _measureCount = 0;
      _totalDb = 0.0;
      _stepResults.clear();
      _currentStep = 0;
      
      _meterAnimation = Tween<double>(
        begin: _meterAnimation.value,
        end: 0,
      ).animate(CurvedAnimation(
        parent: _meterController,
        curve: Curves.easeOutCirc,
      ));
      _meterController.duration = const Duration(milliseconds: 100);
      _meterController.forward(from: 0);
    });
  }

  void _startMeasurement() {
    setState(() {
      _isMeasuring = true;
      _decibels = 0.0;
      // Note: peak, avg, and step data are NOT reset here.
      // This allows users to perform multiple measurement runs
      // and keep the highest peak/accumulated average until 
      // they explicitly hit the 'Reset' button.
      
      if (_currentMode == SoundCheckMode.rev) {
        _currentStep = 0;
      }
    });

    try {
      _noiseSubscription = _noiseMeter?.noise.listen((NoiseReading noiseReading) {
        if (!mounted) return;
        setState(() {
          _decibels = noiseReading.meanDecibel;
          if (_decibels > _peakDb) _peakDb = _decibels;
          _totalDb += _decibels;
          _measureCount++;
          _avgDb = _totalDb / _measureCount;
          
          _meterAnimation = Tween<double>(
            begin: _meterAnimation.value,
            end: _decibels,
          ).animate(CurvedAnimation(
            parent: _meterController, 
            curve: Curves.easeOutQuart
          ));
          _meterController.duration = const Duration(milliseconds: 150);
          _meterController.forward(from: 0);
        });
      }, onError: (Object error) {
        _stopMeasurement();
      });
    } catch (err) {
      _stopMeasurement();
    }
  }

  void _stopMeasurement() {
    _noiseSubscription?.cancel();
    setState(() {
      _isMeasuring = false;
      _isAnalyzing = true;
      _decibels = 0.0;
      _meterAnimation = Tween<double>(begin: _meterAnimation.value, end: 0).animate(_meterController);
      _meterController.forward(from: 0);
    });

    // Simulate analysis delay for "high-fidelity" feel
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    });
  }

  void _nextRevStep() {
    if (_currentStep < 2) {
      setState(() {
        _stepResults[_currentStep] = _decibels;
        _currentStep++;
      });
    } else {
      setState(() {
        _stepResults[_currentStep] = _decibels;
      });
      _stopMeasurement();
    }
  }

  void _showBikePicker() {
    final bikeProvider = Provider.of<BikeProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;

    final List<ExpansionTileController> controllers = List.generate(
      bikeProvider.manufacturers.length,
      (_) => ExpansionTileController(),
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF111111) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'SELECT BIKE FOR LIMITS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: primaryColor.withOpacity(0.4),
                ),
              ),
              const SizedBox(height: 16),
              // Search Bar inside Modal
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    onChanged: (value) {
                      // Internal modal search logic or notify parent
                    },
                    style: TextStyle(color: primaryColor, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search model...',
                      hintStyle: TextStyle(color: primaryColor.withOpacity(0.2)),
                      prefixIcon: Icon(Icons.search, color: primaryColor.withOpacity(0.3), size: 20),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: bikeProvider.isLoading 
                  ? _buildPickerShimmer(isDark)
                  : AnimationLimiter(
                      child: ListView.builder(
                        controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: bikeProvider.manufacturers.length,
                    itemBuilder: (context, mIndex) {
                      final manufacturer = bikeProvider.manufacturers[mIndex];
                      return AnimationConfiguration.staggeredList(
                        position: mIndex,
                        duration: const Duration(milliseconds: 375),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.03),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: primaryColor.withOpacity(0.05)),
                              ),
                              child: Theme(
                                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                child: ExpansionTile(
                                  controller: controllers[mIndex],
                                  expansionAnimationStyle: AnimationStyle(
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeInOutCubic,
                                  ),
                                  onExpansionChanged: (expanded) {
                                    if (expanded) {
                                      for (int i = 0; i < controllers.length; i++) {
                                        if (i != mIndex) controllers[i].collapse();
                                      }
                                    }
                                  },
                                  iconColor: primaryColor.withOpacity(0.3),
                                  collapsedIconColor: primaryColor.withOpacity(0.3),
                                  title: Text(
                                    manufacturer.name.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                      color: primaryColor,
                                    ),
                                  ),
                                  children: manufacturer.bikes.map((bike) {
                                    final isSelected = _selectedBike?.id == bike.id;
                                    return ListTile(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                                      leading: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: (bike.isScooter ? Colors.orange : Colors.blue).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          bike.isScooter ? Icons.moped_rounded : Icons.motorcycle_rounded,
                                          color: bike.isScooter ? Colors.orange : Colors.blue,
                                          size: 20,
                                        ),
                                      ),
                                      title: Text(
                                        bike.name,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: primaryColor.withOpacity(isSelected ? 1.0 : 0.8),
                                        ),
                                      ),
                                      subtitle: Text(
                                        bike.isScooter ? 'SCOOTER • 85dB LIMIT' : 'MOTORCYCLE • 95dB LIMIT',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: primaryColor.withOpacity(0.4),
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20) : null,
                                      onTap: () {
                                        setState(() => _selectedBike = bike);
                                        Navigator.pop(context);
                                      },
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleShare() {
    final bikeName = _selectedBike?.name ?? "Unknown Bike";
    String report = "MotoCheck Sound Test Report\n";
    report += "Bike: $bikeName\n";
    report += "Result: ${_peakDb > _currentLimit ? "FAIL" : "PASS"}\n";
    report += "Peak Sound: ${_peakDb.toStringAsFixed(1)} dB\n";
    report += "Legal Limit: $_currentLimit dB\n";
    report += "Test Date: ${DateTime.now().toString().split('.')[0]}";
    
    Share.share(report);
  }

  void _handleSave() async {
    if (_measureCount == 0 && _stepResults.isEmpty) return;

    final bikeName = _selectedBike?.name ?? "Unknown Bike";
    final manufacturer = _selectedBike?.manufacturerId ?? "Unknown";
    
    final testResult = SoundTestModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      bikeName: bikeName,
      manufacturer: manufacturer,
      peakDb: _peakDb,
      avgDb: _avgDb,
      limitDb: _currentLimit,
      isPass: _peakDb <= _currentLimit,
      timestamp: DateTime.now(),
      mode: _currentMode == SoundCheckMode.normal ? 'normal' : 'rev',
    );

    await Provider.of<SoundProvider>(context, listen: false).saveTest(testResult);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test results saved to your profile'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handlePoliceReport() async {
    final bikeName = _selectedBike?.name ?? "Unknown Bike";
    final uri = Uri(
      scheme: 'mailto',
      path: 'traffic.police@gov.in',
      query: 'subject=Noise Violation Report: $bikeName&body=Official Report from MotoCheck App\n\n'
          'Vehicle Model: $bikeName\n'
          'Measured Noise Level: ${_peakDb.toStringAsFixed(1)} dB\n'
          'Permissible Limit: $_currentLimit dB\n'
          'Violation: ${_peakDb - _currentLimit} dB over limit\n'
          'Timestamp: ${DateTime.now()}\n\n'
          'Note: This measurement was taken using MotoCheck calibrated digital metering.',
    );
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Report Generated'),
          content: const Text('Police reporting email drafted. Please copy the details if the mail app didn\'t open.'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
        ),
      );
    }
  }

  @override
  void dispose() {
    _noiseSubscription?.cancel();
    _meterController.dispose();
    _pulseController.dispose();
    _headerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final targetPrimaryColor = _currentMode == SoundCheckMode.normal ? Colors.green : Colors.red;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: TweenAnimationBuilder<Color?>(
        duration: const Duration(milliseconds: 300),
        tween: ColorTween(end: targetPrimaryColor),
        builder: (context, primaryColor, child) {
          final pColor = primaryColor ?? targetPrimaryColor;
          return SafeArea(
            child: AnimationLimiter(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: AnimationConfiguration.toStaggeredList(
                    duration: const Duration(milliseconds: 600),
                    childAnimationBuilder: (widget) => SlideAnimation(
                      verticalOffset: 20.0,
                      child: FadeInAnimation(child: widget),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
                        child: _buildHeader(context, isDark, textColor),
                      ),
                      const SizedBox(height: 8),
                      Center(child: _buildModeToggle(isDark, pColor)),
                      const SizedBox(height: 32),
                      _buildSoundMeter(isDark, pColor),
                      const SizedBox(height: 32),
                      if (_selectedBike != null) ...[
                        Text(
                          '${_selectedBike!.name} • ${_selectedBike!.manufacturerId}'.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white54 : Colors.black54,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      _buildStartStopButton(isDark, pColor),
                      const SizedBox(height: 32),
                      _buildLiveDataRow(isDark),
                      
                      if (_currentMode == SoundCheckMode.rev && _isMeasuring) ...[
                        const SizedBox(height: 32),
                        _buildRevModeSteps(isDark, pColor),
                      ],
                      
                      if (_isAnalyzing) ...[
                        const SizedBox(height: 32),
                        _buildAnalysisShimmer(isDark),
                      ],
                      
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        switchInCurve: Curves.easeOutCubic,
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.05),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                              child: child,
                            ),
                          );
                        },
                        child: (!_isMeasuring && !_isAnalyzing && (_measureCount > 0 || _stepResults.isNotEmpty))
                            ? Column(
                                key: const ValueKey('results_block'),
                                children: [
                                  const SizedBox(height: 32),
                                  _buildResultSection(isDark, pColor),
                                  const SizedBox(height: 24),
                                  _buildActions(isDark, pColor),
                                  const SizedBox(height: 16),
                                  _buildLegalComparison(isDark),
                                  const SizedBox(height: 16),
                                  _buildSuggestions(isDark),
                                  const SizedBox(height: 40),
                                  _buildDisclaimer(isDark),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, Color textColor) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: textColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: textColor.withOpacity(0.05)),
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded, color: textColor, size: 20),
          ),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MEASUREMENT',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: textColor.withOpacity(0.38),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'SOUND CHECK',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                color: textColor,
              ),
            ),
          ],
        ),
        const Spacer(),
        if (!_isMeasuring && (_measureCount > 0 || _stepResults.isNotEmpty))
          GestureDetector(
            onTap: _reset,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: textColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.refresh_rounded, color: textColor, size: 20),
            ),
          ),
      ],
    );
  }

  Widget _buildModeToggle(bool isDark, Color primaryColor) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            alignment: _currentMode == SoundCheckMode.normal ? Alignment.centerLeft : Alignment.centerRight,
            child: Container(
              width: 126,
              height: 40,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Row(
            children: [
              _buildToggleItem('Normal Mode', SoundCheckMode.normal, isDark),
              _buildToggleItem('Rev Mode', SoundCheckMode.rev, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem(String label, SoundCheckMode mode, bool isDark) {
    final isSelected = _currentMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() { if (!_isMeasuring) _currentMode = mode; }),
        child: Container(
          height: 40,
          color: Colors.transparent,
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : (isDark ? Colors.white38 : Colors.black38),
                fontFamily: 'Roboto',
              ),
              child: Text(label),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSoundMeter(bool isDark, Color primaryColor) {
    return AnimatedBuilder(
      animation: _meterAnimation,
      builder: (context, child) {
        final val = _meterAnimation.value;
        final dbColor = _getDecibelColor(val);
        
        return Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: dbColor.withOpacity(_isMeasuring ? 0.15 : 0.05),
                        blurRadius: 40,
                        spreadRadius: 10,
                      )
                    ],
                  ),
                ),
                SizedBox(
                  width: 280,
                  height: 280,
                  child: CustomPaint(
                    painter: MeterPainter(
                      value: val,
                      max: 120,
                      isDark: isDark,
                      color: dbColor,
                      limit: _currentLimit,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.scale(
                      scale: _isMeasuring ? 1.0 + (val / 120 * 0.1) : 1.0,
                      child: Text(
                        val.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 72, 
                          fontWeight: FontWeight.w900, 
                          color: isDark ? Colors.white : Colors.black, 
                          letterSpacing: -2, 
                          height: 1
                        ),
                      ),
                    ),
                    Text(
                      'dB', 
                      style: TextStyle(
                        fontSize: 20, 
                        fontWeight: FontWeight.w900, 
                        color: isDark ? Colors.white38 : Colors.black38
                      )
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'LIMIT: ${_currentLimit.toInt()} dB', 
                        style: TextStyle(
                          fontSize: 11, 
                          fontWeight: FontWeight.w900, 
                          color: primaryColor,
                          letterSpacing: 0.5,
                        )
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStartStopButton(bool isDark, Color pColor) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
      child: _selectedBike == null
          ? _buildChooseBikeButton(isDark)
          : _buildMeasureButton(isDark, pColor),
    );
  }

  Widget _buildChooseBikeButton(bool isDark) {
    return GestureDetector(
      key: const ValueKey('choose_bike'),
      onTap: _showBikePicker,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final pulse = _pulseController.value;
          return Transform.scale(
            scale: 1.0 + (pulse * 0.02),
            child: Container(
              width: 240, 
              height: 72,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: isDark ? Colors.white : Colors.black,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? Colors.white : Colors.black).withOpacity(0.15 + (pulse * 0.1)),
                    blurRadius: 20 + (pulse * 10),
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.directions_bike_rounded,
                    color: isDark ? Colors.black : Colors.white,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'CHOOSE BIKE',
                    style: TextStyle(
                      color: isDark ? Colors.black : Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMeasureButton(bool isDark, Color bColor) {
    return GestureDetector(
      key: const ValueKey('start_stop'),
      onTap: _toggleMeasurement,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final pulseValue = _pulseController.value;
          final buttonColor = _isMeasuring ? Colors.grey[900]! : bColor;
          
          return AnimatedScale(
            scale: _isMeasuring ? 1.05 : 1.0 + (pulseValue * 0.02),
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              width: 240, 
              height: 72,
              decoration: BoxDecoration(
                color: buttonColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: buttonColor.withOpacity(0.3 + (0.2 * pulseValue)),
                    blurRadius: _isMeasuring ? 25 + (15 * pulseValue) : 20,
                    spreadRadius: _isMeasuring ? 2 : 0,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isMeasuring ? Icons.stop_rounded : Icons.mic_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 60, 
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
                        return Stack(
                          alignment: Alignment.centerLeft, 
                          children: <Widget>[
                            ...previousChildren,
                            if (currentChild != null) currentChild,
                          ],
                        );
                      },
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        final isEntering = (child.key as ValueKey<bool>).value == _isMeasuring;
                        
                        final curvedAnimation = CurvedAnimation(
                          parent: animation,
                          curve: const Interval(0.0, 1.0, curve: Curves.elasticOut),
                          reverseCurve: Curves.easeInBack,
                        );

                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: isEntering ? const Offset(0.0, -1.2) : const Offset(0.0, 1.2),
                              end: Offset.zero,
                            ).animate(curvedAnimation),
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        _isMeasuring ? 'STOP' : 'START',
                        key: ValueKey(_isMeasuring),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  const Text(
                    'CHECK',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }


  Widget _buildLiveDataRow(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLiveDataItem('LIMIT', '${_currentLimit.toInt()}', isDark),
          _buildLiveDivider(isDark),
          _buildLiveDataItem('PEAK', _peakDb.toStringAsFixed(1), isDark),
          _buildLiveDivider(isDark),
          _buildLiveDataItem('AVG', _avgDb.toStringAsFixed(1), isDark),
        ],
      ),
    );
  }

  Widget _buildLiveDataItem(String label, String value, bool isDark) {
    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: Text(
            value, 
            key: ValueKey(value),
            style: TextStyle(
              fontSize: 22, 
              fontWeight: FontWeight.w900, 
              color: isDark ? Colors.white : Colors.black
            )
          ),
        ),
        Text(
          label, 
          style: TextStyle(
            fontSize: 10, 
            fontWeight: FontWeight.w800, 
            color: isDark ? Colors.white24 : Colors.black26, 
            letterSpacing: 1
          )
        ),
      ],
    );
  }

  Widget _buildLiveDivider(bool isDark) {
    return Container(height: 25, width: 1, color: isDark ? Colors.white12 : Colors.black12);
  }

  Widget _buildRevModeSteps(bool isDark, Color primaryColor) {
    final steps = ['IDLE', 'MID-REV', 'PEAK-REV'];
    final instructions = [
      'Keep the bike at steady idle. We are measuring the baseline noise.',
      'Rev the engine to approximately 50% of its RPM range.',
      'Perform a full rev to capture the maximum exhaust note.'
    ];

    final stepColors = [
      const Color(0xFF4CAF50), // Green for Idle
      const Color(0xFFFFC107), // Amber for Mid
      const Color(0xFFFF5252), // Red for Peak
    ];

    final currentStageColor = stepColors[_currentStep];
    final textColor = isDark ? Colors.white : Colors.black;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeInQuint,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.2, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey(_currentStep),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: currentStageColor.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: currentStageColor.withOpacity(0.1),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.5 : 0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Stack(
            children: [
              // Subtle background gradient reflecting the stage
              Positioned(
                right: -50,
                top: -50,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        currentStageColor.withOpacity(0.15),
                        currentStageColor.withOpacity(0),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Step Indicator Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        final isActive = _currentStep == index;
                        final isCompleted = _currentStep > index;
                        final color = isCompleted
                            ? Colors.green
                            : (isActive ? currentStageColor : textColor.withOpacity(0.1));

                        return Row(
                          children: [
                            Column(
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    if (isActive)
                                      _buildPulseRing(currentStageColor),
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 400),
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: isDark ? Colors.black : Colors.white,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: color,
                                          width: isActive ? 3 : 2,
                                        ),
                                        boxShadow: isActive ? [
                                          BoxShadow(
                                            color: color.withOpacity(0.3),
                                            blurRadius: 10,
                                          )
                                        ] : [],
                                      ),
                                      child: Center(
                                        child: isCompleted
                                            ? const Icon(Icons.check_rounded, size: 24, color: Colors.green)
                                            : Text(
                                                '${index + 1}',
                                                style: TextStyle(
                                                  color: isActive ? textColor : textColor.withOpacity(0.3),
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 16,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  ['IDLE', 'MID', 'PEAK'][index],
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1,
                                    color: isActive ? color : textColor.withOpacity(0.2),
                                  ),
                                ),
                              ],
                            ),
                            if (index < 2)
                              Container(
                                width: 40,
                                height: 3,
                                margin: const EdgeInsets.only(bottom: 18, left: 8, right: 8),
                                decoration: BoxDecoration(
                                  color: textColor.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: OverflowBox(
                                  alignment: Alignment.centerLeft,
                                  maxWidth: 40,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 600),
                                    width: isCompleted ? 40 : 0,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      }),
                    ),
                    const SizedBox(height: 32),
                    // Current DB Bar for the stage
                    Container(
                      height: 60,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: textColor.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.graphic_eq_rounded, color: currentStageColor, size: 20),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'LIVE INTENSITY',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1,
                                        color: textColor.withOpacity(0.4),
                                      ),
                                    ),
                                    Text(
                                      '${_decibels.toStringAsFixed(1)} dB',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                        color: textColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: (_decibels / 120).clamp(0, 1),
                                    backgroundColor: textColor.withOpacity(0.05),
                                    valueColor: AlwaysStoppedAnimation<Color>(currentStageColor),
                                    minHeight: 6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      steps[_currentStep],
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        instructions[_currentStep],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: textColor.withOpacity(0.6),
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Action Button
                    GestureDetector(
                      onTap: _nextRevStep,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                        decoration: BoxDecoration(
                          color: currentStageColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: currentStageColor.withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _currentStep < 2 ? 'NEXT STAGE' : 'FINISH TEST',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPulseRing(Color color) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          width: 44 + (_pulseController.value * 20),
          height: 44 + (_pulseController.value * 20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withOpacity(1.0 - _pulseController.value),
              width: 2,
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultSection(bool isDark, Color primaryColor) {
    final isIllegal = _peakDb > _currentLimit;
    final verdict = isIllegal ? 'ILLEGAL / OVER LIMIT' : 'LEGAL / WITHIN LIMIT';
    final verdictColor = isIllegal ? Colors.red : Colors.green;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('FINAL ANALYSIS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.grey)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF111111) : Colors.grey[100], 
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                _buildResultRow('MAX MEASURED', '${_peakDb.toStringAsFixed(1)} dB', isDark),
                const SizedBox(height: 8),
                _buildResultRow('BIKE LIMIT', '$_currentLimit dB', isDark),
                const Divider(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('VERDICT', style: TextStyle(fontWeight: FontWeight.w900)),
                    Text(
                      verdict,
                      style: TextStyle(fontWeight: FontWeight.w900, color: verdictColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ],
    );
  }

  Widget _buildLegalComparison(bool isDark) {
    final diff = _peakDb - _currentLimit;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: (diff > 0 ? Colors.red : Colors.green).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
        child: Text(
          diff > 0 ? 'Your vehicle is ${diff.toStringAsFixed(1)} dB louder than the permissible limit for this model.' : 'Your vehicle is well within the legal noise limit of $_currentLimit dB.',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w800, color: diff > 0 ? Colors.red : Colors.green),
        ),
      ),
    );
  }

  Widget _buildSuggestions(bool isDark) {
    final suggestions = _peakDb > _currentLimit 
      ? ['Install a DB Killer / Silencer', 'Check for muffler holes', 'Report this to authorities']
      : ['Exhaust is stock / compliant', 'Keep up the good maintenance', 'Safe for residential areas'];
    
    return Column(
      children: suggestions.map((s) => ListTile(leading: const Icon(Icons.check_circle_outline, size: 20), title: Text(s, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)))).toList(),
    );
  }

  Widget _buildPickerShimmer(bool isDark) {
    final baseColor = isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05);
    final highlightColor = isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 6,
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisShimmer(bool isDark) {
    final baseColor = isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05);
    final highlightColor = isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Column(
          children: [
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: Container(height: 60, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)))),
                const SizedBox(width: 16),
                Expanded(child: Container(height: 60, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(bool isDark, Color primaryColor) {
    final hasData = _measureCount > 0 || _stepResults.isNotEmpty;
    final isIllegal = hasData && _peakDb > _currentLimit;
    final btnColor = isDark ? Colors.white : Colors.black;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildActionBtn('SAVE TEST', Icons.save_alt, isDark, hasData ? btnColor : Colors.grey, false, hasData ? _handleSave : () {})),
              const SizedBox(width: 16),
              Expanded(child: _buildActionBtn('SHARE', Icons.share, isDark, hasData ? btnColor : Colors.grey, true, hasData ? _handleShare : () {})),
            ],
          ),
          if (isIllegal) ...[
            const SizedBox(height: 16),
            _buildActionBtn('REPORT VIOLATION TO POLICE', Icons.gavel_rounded, isDark, Colors.red, true, _handlePoliceReport),
          ],
        ],
      ),
    );
  }

  Widget _buildActionBtn(String label, IconData icon, bool isDark, Color color, bool filled, VoidCallback onTap) {
    final contentColor = filled ? (color == Colors.white ? Colors.black : Colors.white) : color;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(color: filled ? color : Colors.transparent, borderRadius: BorderRadius.circular(16), border: Border.all(color: color)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: contentColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: contentColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisclaimer(bool isDark) {
    return const Padding(padding: EdgeInsets.symmetric(horizontal: 40), child: Text('MotoCheck is not a legal tool. Measurements can vary by device hardware quality.', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: Colors.grey)));
  }

  Color _getDecibelColor(double db) {
    if (db < _currentLimit - 10) return Colors.green;
    if (db < _currentLimit) return Colors.orange;
    return Colors.red;
  }
}

class MeterPainter extends CustomPainter {
  final double value;
  final double max;
  final bool isDark;
  final Color color;
  final double limit;

  MeterPainter({required this.value, required this.max, required this.isDark, required this.color, required this.limit});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 12.0;

    final paintGlow = Paint()
      ..color = color.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 8
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius - strokeWidth / 2), math.pi * 0.75, math.pi * 1.5, false, paintGlow);

    final paintBase = Paint()
      ..color = isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius - strokeWidth / 2), math.pi * 0.75, math.pi * 1.5, false, paintBase);

    final limitAngle = math.pi * 0.75 + (limit / max) * math.pi * 1.5;
    final paintLimit = Paint()
      ..color = Colors.red.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    
    final tickInner = Offset(
      center.dx + (radius - strokeWidth - 5) * math.cos(limitAngle),
      center.dy + (radius - strokeWidth - 5) * math.sin(limitAngle),
    );
    final tickOuter = Offset(
      center.dx + (radius + 5) * math.cos(limitAngle),
      center.dy + (radius + 5) * math.sin(limitAngle),
    );
    canvas.drawLine(tickInner, tickOuter, paintLimit);

    final paintValue = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    
    final sweepAngle = (value / max) * math.pi * 1.5;
    if (sweepAngle > 0.01) {
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius - strokeWidth / 2), math.pi * 0.75, sweepAngle.clamp(0.01, math.pi * 1.5), false, paintValue);
    }
    
    if (value > 0) {
      final endAngle = math.pi * 0.75 + sweepAngle;
      final endPoint = Offset(
        center.dx + (radius - strokeWidth / 2) * math.cos(endAngle),
        center.dy + (radius - strokeWidth / 2) * math.sin(endAngle),
      );
      
      final paintEnd = Paint()..color = Colors.white..style = PaintingStyle.fill;
      canvas.drawCircle(endPoint, 4, paintEnd);
      
      final paintEndStroke = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2;
      canvas.drawCircle(endPoint, 5, paintEndStroke);
    }
  }

  @override
  bool shouldRepaint(covariant MeterPainter oldDelegate) => true;
}
