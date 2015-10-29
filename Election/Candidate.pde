class Candidate {
  
  String firstName, lastName, party, id;
  
  Candidate(String fullName, String candidateParty, String candidateId) {
    String[] splitName = fullName.split(", ");
    firstName = splitName[1];
    lastName = splitName[0];
    if(candidateParty.contains("R")) party = "Republican";
    else if(candidateParty.contains("D")) party = "Democrat";
    else party = "Other";
    id = candidateId;
  }
  
  public String toString() {
    return this.firstName + " " + this.lastName + " (" + this.party + ")";
  }
  
}