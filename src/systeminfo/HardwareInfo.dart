class Hardwareinfo {
    String name;
    List<double> utilization = [0];

    Hardwareinfo({
        required this.name
    });

    Future<void> updateDynamicStats() async {
        throw "child classes must implement updateDynamicStats";
    }
}