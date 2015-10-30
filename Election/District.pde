class District {
  State state;
  String number;
  HashMap < Candidate, Float > candidates;
  PShape district;
  PShape country;
  String stateCode;
  color districtColor;
  ArrayList < Candidate > array;


  District(State parentState, String districtNo, PShape map) {
    state = parentState;
    number = districtNo;
    candidates = new HashMap < Candidate, Float > ();
    country = map;
    districtColor = color(0, 0, 0);

  }

  void setUp() {
    if (number.equals("S") == false) {
      if (number.equals("00") == true) {
        stateCode = state.abbreviation + "_" + "At-Large";
      } else if (number.charAt(0) == '0') {
        stateCode = state.abbreviation + "_" + number.substring(1);
      } else {
        stateCode = state.abbreviation + "_" + number;
      }
      district = country.getChild(stateCode);
    }
    setDistrictColor();
  }

  ArrayList < Candidate > getTop2() {
    int index = 0;
    array = new ArrayList < Candidate > ();
    Candidate runnerUp = new Candidate("a, a", "30");
    Candidate winner = new Candidate("b, v", "30");
    for (Candidate candidate: candidates.keySet()) {
      if (index == 0) winner = candidate;
      else runnerUp = candidate;
      index += 1;
    }
    if (candidates.get(runnerUp) != null) {
      if (candidates.get(winner) > candidates.get(runnerUp)) {
        array.add(winner);
        array.add(runnerUp);
      } else {
        array.add(runnerUp);
        array.add(winner);
      }
    } else {
      array.add(winner);
      array.add(new Candidate("nA, nB", "2"));
    }
    return array;

  }

  /*Candidates getRunnerUp(int year) {
    Candidate RunnerUp = new Candidate("b, v", "R");
    int index = 0;
    for(Candidate candidate : candidates.keySet()) {
      if(index == 1) {
        RunnerUp = candidate;
      }
      index += 1;
    }
    return RunnerUp;
  }*/

  void setDistrictColor() {
    Candidate winner = this.getTop2().get(0);
    Candidate runnerUp = this.getTop2().get(1);
    float difference = 0.50000;
    if (this.getTop2().get(0) != null && this.candidates.get(runnerUp) != null) difference = this.candidates.get(winner) / (this.candidates.get(winner) + this.candidates.get(runnerUp));
    else difference = 1.0;
    if (this.getTop2().get(0).party == "Republican") {
      if (difference > 0.85) districtColor = color(24, 10, 4);
      else if (difference > 0.65) districtColor = color(34, 20, 14);
      else districtColor = color(44, 30, 24);
    } else {
      if (difference > 0.75) districtColor = color(28, 40, 65);
      else if (difference > 0.55) districtColor = color(38, 50, 75);
      else districtColor = color(48, 60, 85);
    }

  }

}
