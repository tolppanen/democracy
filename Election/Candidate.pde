class Candidate {
  
  String firstName, lastName, party, fullName;
  
  Candidate(String fullName, String candidateParty) {
    String[] splitName = fullName.split(", ");
    firstName = splitName[1];
    lastName = splitName[0];
    fullName = firstName + " " + lastName;
    if(candidateParty.contains("R")) party = "Republican";
    else if(candidateParty.contains("D")) party = "Democrat";
    else party = "Other";
  }
  
  public String toString() {
    return this.firstName + " " + this.lastName + " (" + this.party + ")";
  }
  
}