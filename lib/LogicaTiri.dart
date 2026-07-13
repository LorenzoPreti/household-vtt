class LogicaTiri {
  static Map<String, dynamic> analizzaRisultato(List<int> dati) {
    List<int> frequenze = [0, 0, 0, 0, 0, 0];
    var dadiRitirabili = 0;
    Map<String, int> successi = {
      "Base": 0,
      "Critico": 0,
      "Estremo": 0,
      "Impossibile": 0,
      "Successone": 0,
    };

    for (var d = 0; d < dati.length; d++) {
      frequenze[dati[d] - 1]++;  // semplificato
    }

    for (var i = 0; i < 6; i++) {
      if (frequenze[i] == 1) dadiRitirabili++;
      if (frequenze[i] == 2) successi["Base"] = successi["Base"]! + 1;
      if (frequenze[i] == 3) successi["Critico"] = successi["Critico"]! + 1;
      if (frequenze[i] == 4) successi["Estremo"] = successi["Estremo"]! + 1;
      if (frequenze[i] == 5) successi["Impossibile"] = successi["Impossibile"]! + 1;
      if (frequenze[i] == 6) successi["Successone"] = successi["Successone"]! + 1;
    }

    return {
      "successi": successi,
      "dadiRitirabili": dadiRitirabili,
      "frequenze": frequenze
    };
  }
}