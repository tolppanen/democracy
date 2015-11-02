import de.bezier.data.*;
import java.util.*;
import java.lang.Exception.*;
// KINECT
import SimpleOpenNI.*;
SimpleOpenNI kinect;
boolean select = false;
boolean drag = false;
boolean tracking = false;
int handVecListSize = 20;
Map < Integer, ArrayList < PVector >> handPathList = new HashMap < Integer, ArrayList < PVector >> ();
color[] userClr = new color[] {
  color(255, 0, 0),
  color(0, 255, 0),
  color(0, 0, 255),
  color(255, 255, 0),
  color(255, 0, 255),
  color(0, 255, 255)
};
PVector cursor;
// /KINECT

XlsReader reader;
JSONObject json;
PShape map;
Boolean locked;
int startX;
int startY;
int origoX = 0;
int origoY = 0;
float zoomX = 1024;
float zoomY = 617;
float zoomYX = 1024 / 617;
int x;
int y;
int year = 2012;
boolean firstPressed = true;
PShape hiddenMap; // hidden Map
ArrayList < State > states;
District activeDistrict;
PImage pic;
Boolean mapMode;
Ball[] balls = new Ball[235];
String activeYear;
PImage detailImg;
boolean imgLoaded;
District loadedDistrict;
String nameQueryString;

void setup() {
  size(1200, 680);
  noSmooth(); // Disable AA for performance
  //smooth(2); // Anti-aliasing
  activeYear = "2012";
  frame.setResizable(true);
  setupData(2012);
  mapMode = true;
  setupBalls();
  setupKinect();
  thread("drawKinect"); // Thread Kinect to allow proper update speed
}

void draw() {
  background(242, 242, 242);
  if (mapMode) {
    drawHiddenStates();
    drawVisibleStates();
    drawMenu();
    //drawKinect(); // Uncomment for non-threaded testing
    if (select) drawInfo();
    updateDrag();
  } else if (!mapMode) {
    drawBalls();
    drawMenu();
  }
  fill(255, 255, 255);
  ellipse(cursor.x, cursor.y, 20, 20);
}

void setupData(int electionYear) {
  states = new ArrayList < State > ();
  reader = new XlsReader(this, "data/formatted_data_" + electionYear + ".xls");
  reader.firstRow();
  map = loadShape("data/us_congressional_districts.svg");
  hiddenMap = loadShape("data/us_congressional_districts.svg");

  int col = 0;
  int row = 0;
  while (reader.hasMoreRows()) {
    int previousrow = Math.max(row - 1, 0);
    if (reader.getString(row, col + 2) != reader.getString(previousrow, col + 2)) {
      for (int i = 0; i < 2; i++) {
        col = 0;
        String stateAbbreviation = reader.getString(row, col);
        String state = reader.getString(row, col + 1);
        State currentState;
        if (states.size() == 0 || states.get(states.size() - 1).name != state) {
          currentState = new State(state, stateAbbreviation);
          states.add(currentState);
        } else currentState = states.get(states.size() - 1);
        String district = reader.getString(row, col + 2);
        District currentDistrict;
        if (currentState.districts.size() == 0 || currentState.districts.get(currentState.districts.size() - 1).number != district) {
          currentDistrict = new District(currentState, district, map);
          currentState.districts.add(currentDistrict);
        } else currentDistrict = currentState.districts.get(currentState.districts.size() - 1);
        String name = reader.getString(row, col + 4);
        String party = reader.getString(row, col + 5);
        Float votePercent = reader.getFloat(row, col + 7) * 100;
        Candidate newCandidate = new Candidate(name, party);
        currentDistrict.candidates.put(newCandidate, votePercent);
        reader.nextRow();
        row = row + 1;
      }
    } else {
      reader.nextRow();
      row = row + 1;
    }
  }

  for (int i = 0; i < states.size(); i++) {
    for (int j = 0; j < states.get(i).districts.size(); j++) {
      states.get(i).districts.get(j).setUp();
      states.get(i).districts.get(j).getTop2();
    }
  }
}

void drawVisibleStates() {
  State current_s;
  District current_d;
  stroke(color(255, 255, 255));
  //hint(ENABLE_STROKE_PURE); // Uncomment for better quality strokes at the cost of performance
  for (int j = 0; j < states.size(); j++) {
    current_s = states.get(j);
    for (int i = 0; i < current_s.districts.size(); i++) {
      current_d = current_s.districts.get(i);
      if (current_d.district != null) {
        current_d.district.disableStyle();
        fill(current_d.districtColor);
        shape(current_d.district, x, y, zoomX, zoomY);
      }
    }
  }
  if (activeDistrict != null) {
    //activeDistrict.district.disableStyle();
    String districtDesc = activeDistrict.state.abbreviation + " - " + activeDistrict.number;
    fill(0, 0, 0, 50);
    shape(activeDistrict.district, x, y, zoomX, zoomY);
    stroke(0, 0, 0);
    fill(219, 189, 149);
    rect((int) cursor.x + 15, (int) cursor.y - 30, 100, 30);
    fill(100);
    textSize(13);
    text(districtDesc, (int) cursor.x + 45, (int) cursor.y - 22, 150, 40);
  }
}

void drawHiddenStates() {
  State current_s;
  District current_d;
  for (int j = 0; j < states.size(); j++) {
    current_s = states.get(j);
    for (int i = 0; i < current_s.districts.size(); i++) {
      current_d = current_s.districts.get(i);
      if (current_d.district != null) {
        current_d.district.disableStyle();
        color c = color(j, i, 0);
        fill(c);
        shape(current_d.district, x, y, zoomX, zoomY);
        if (get((int) cursor.x, (int) cursor.y) == c) {
          activeDistrict = current_d;
        }
      }
    }
  }
}

void drawMenu() {
  int textwidth = width / 13;
  fill(65, 65, 65, 191);
  noStroke();
  rect(0, height - 35, width, height);
  fill(255, 255, 255);
  PFont font;
  font = loadFont("Kalinga-48.vlw");
  textFont(font, 16);

  if (activeYear == "2002") fill(0, 0, 0);
  text(2002, textwidth * 1, height - 10);
  fill(255, 255, 255);
  if (activeYear == "2004") fill(0, 0, 0);
  text(2004, textwidth * 3, height - 10);
  fill(255, 255, 255);
  if (activeYear == "2006") fill(0, 0, 0);
  text(2006, textwidth * 5, height - 10);
  fill(255, 255, 255);
  if (activeYear == "2008") fill(0, 0, 0);
  text(2008, textwidth * 7, height - 10);
  fill(255, 255, 255);
  if (activeYear == "2010") fill(0, 0, 0);
  text(2010, textwidth * 9, height - 10);
  fill(255, 255, 255);
  if (activeYear == "2012") fill(0, 0, 0);
  text(2012, textwidth * 11, height - 10);
}

void updateDrag() {
  if (drag) {
    if (firstPressed) {
      startX = (int) cursor.x;
      startY = (int) cursor.y;
      firstPressed = false;
      return;
    }
    x = origoX + ((int) cursor.x - startX);
    y = origoY + ((int) cursor.y - startY);
  }
}

void mousePressed() {
  if (firstPressed) {
    firstPressed = false;
    startX = mouseX;
    startY = mouseY;
  }
}

void mouseDragged() {
  x = origoX + (mouseX - startX);
  y = origoY + (mouseY - startY);
}

void mouseReleased() {
  firstPressed = true;
  origoX = x;
  origoY = y;
}

void drawInfo() {
  int textBox = width / 13;
  if ((int) cursor.y > height - 20) {
    if ((int) cursor.x > textBox && (int) cursor.x < textBox * 2) {
      setupData(2002);
      setupBalls();
      activeYear = "2002";
    } else if ((int) cursor.x > textBox * 3 && (int) cursor.x < textBox * 4) {
      setupData(2004);
      setupBalls();
      activeYear = "2004";
    } else if ((int) cursor.x > textBox * 5 && (int) cursor.x < textBox * 6) {
      setupData(2006);
      setupBalls();
      activeYear = "2006";
    } else if ((int) cursor.x > textBox * 7 && (int) cursor.x < textBox * 8) {
      setupData(2008);
      setupBalls();
      activeYear = "2008";
    } else if ((int) cursor.x > textBox * 9 && (int) cursor.x < textBox * 10) {
      setupData(2010);
      setupBalls();
      activeYear = "2010";
    } else {
      setupData(2012);
      setupBalls();
      activeYear = "2012";
    }
  } else {
    ArrayList < Candidate > top2 = activeDistrict.getTop2();
    Candidate winner = top2.get(0);
    Candidate runnerup = top2.get(1);
    fill(45, 45, 45, 191);
    rect(width - 400, 35, 365, 550, 7);
    String headline = activeDistrict.state.name + "'s " + activeDistrict.number + "th " + "\n" + "Congressional District";
    textSize(20);
    fill(255, 255, 255);
    text(headline, width - 380, 70);
    String winningpercent = String.format("%.1f", activeDistrict.candidates.get(winner));
    String runningUppercent = String.format("%.1f", activeDistrict.candidates.get(runnerup));
    nameQueryString = winner.firstName + "_" + winner.lastName;
    String RUfirstName = runnerup.firstName;
    String RUlastName = runnerup.lastName;
    text(winner.firstName + " " + winner.lastName + " - " + winner.party +
      " " + winningpercent + "%" +
      "\n" + "\n" + "\n" + "\n" + "\n" + "Runner Up:" + "\n" + RUfirstName + " " + RUlastName + " - " + runnerup.party + " " + runningUppercent + "%", width - 380, 400);

    if (!imgLoaded || loadedDistrict != activeDistrict) thread("loadImg"); // If no image loaded or district changed, download image in a thread.
    if (imgLoaded && loadedDistrict == activeDistrict) image(detailImg, width - 350, 150); // Draw image
  }
}

void loadImg() {
  String link = "https://en.wikipedia.org/w/api.php?action=query&titles=" + nameQueryString + "&prop=pageimages&format=json&pithumbsize=200";
  String url = "http://pcforalla.idg.se/polopoly_fs/1.539126.1386947577!teaserImage/imageTypeSelector/localImage/3217596809.jpg";
  String web = loadStrings(link)[0];
  if (web.charAt(0) == '{' && web.contains("http")) {
    JSONObject json = loadJSONObject(link);
    JSONObject query = json.getJSONObject("query");
    JSONObject pages = query.getJSONObject("pages");
    String page = pages.toString();
    int startLink = page.indexOf("http");
    int endLink = 2;
    if (page.contains(".jpeg")) {
      endLink = page.indexOf(".jpeg\"") + 5;
    } else {
      endLink = page.indexOf(".jpg\"") + 4;
    }
    url = page.substring(startLink, endLink);
  }
  detailImg = loadImage(url);
  imgLoaded = true;
  loadedDistrict = activeDistrict;
}

void keyPressed() {
  if (keyCode == UP) {
    zoomY += 25;
    zoomX += 25 * zoomYX;
  }
  if (keyCode == DOWN) {
    zoomY -= 25;
    zoomX -= 25 * zoomYX;
  }
  if (keyCode == CONTROL) {
    zoomX = 1024;
    zoomY = 617;
  }
  if (keyCode == SHIFT) {
    setupData(2010);
    setupBalls();
  }
  if (key == 'b') { // b, Test drag
    firstPressed = true;
    if (!drag) drag = true;
    else drag = false;
  }
  if (keyCode == 65) { // a
    mapMode = false;
  }
  if (keyCode == 32) { // Space, test drawInfo
    if (!select) select = true;
    else {
      select = false;
    }
  }
}

//Placeholder implementation for changing year
void keyReleased() {
  if (keyCode == SHIFT) {
    setupData(2012);
    setupBalls();
  }
  if (keyCode == 32) {
    //select = false;
    //detailView = false;
    //loop();
    //info = false;
  }
  if (keyCode == 65) { // A
    mapMode = true;
  }
}
