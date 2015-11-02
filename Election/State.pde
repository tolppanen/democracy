class State {
  String name, abbreviation;
  ArrayList < District > districts;

  State(String stateName, String stateAbbreviation) {
    name = stateName;
    abbreviation = stateAbbreviation;
    districts = new ArrayList < District > ();
  }

  public String toString() {
    return this.name;
  }
}
