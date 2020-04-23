import processing.video.*;
import java.util.ArrayList;

String[] movieNames = {"sample_1.mp4", "sample_2.mp4", "sample_3.mp4", "sample_4.mp4"};  //Video File Names
int[] mmNum = {1, 6};  // Min, Max Movie Number
int[] mmDelay = {1000, 2000};  //Min, Max New Movie Delay msec
int[] mmX = {0, 500};  //Min, Max X Position
int[] mmY = {0, 400};  //Min, Max Y Position
int[] mmXsize = {100, 600};  //Min, Max Width
int[] mmYsize = {100, 500};  //Min, Max Height
int[] mmPlay = {5000, 7000};  //Min, Max Play Time

ArrayList<MyMovie> MyMovies = new ArrayList<MyMovie>();  //Movie Array
ArrayList<MyMovie> YourMovies = new ArrayList<MyMovie>();  //Movie Array

// Only One Time Run
void setup(){
  size(740, 580);  //Canvas Size(Width, Height)
  frameRate(60);  //Canvas Frame Rate
  for(int i=0; i<mmNum[1]; i++){
    YourMovies.add(new MyMovie(this));
  }
  AddThread addThread = new AddThread();
  addThread.setDaemon(true);
  addThread.start();
  
  //addTh Function Thread Run
  RemoveThread removeThread = new RemoveThread();
  removeThread.setDaemon(true);
  removeThread.start();
}

// Loop Run
void draw(){
  background(0);  // Canvas Background Color
  try{  
    if(!MyMovies.isEmpty()){  // Not Empty List
      for(MyMovie m : MyMovies){  // Sequencially Search
        image(m.movie, m.xPos, m.yPos, m.xSize, m.ySize);  // Draw Movie Frame by Image(movie, X, y, Width, Height)
      }
    }
  }catch(Exception e){}
}

void movieEvent (Movie m) {  // Read Movie Event
  m.read();
}

public class MyMovie{  // Custom Class
  int xPos;  // X Position
  int yPos;  // Y Position
  int xSize;  // Width
  int ySize;  // Height
  Movie movie;
  Boolean isStop = false;
  
  public MyMovie(PApplet app){  // CTOR
    movie = new Movie(app,movieNames[int(random(0,4))]);
    movie.frameRate(20);
  }
  
  void refresh(){
    xPos = int(random(mmX[0],mmX[1]));  //Random between Min and Max
    yPos = int(random(mmY[0],mmY[1]));
    xSize = int(random(mmXsize[0],mmXsize[1]));
    ySize = int(random(mmYsize[0],mmYsize[1]));
    //println("dur :",movie.duration(), "sec");
    float tmp = random(movie.duration());
    println("start :",tmp,"sec");
    movie.jump(tmp);  // Random Start Point
    movie.play();
    isStop = false;
  }
}

public class AddThread extends Thread{
  @Override
  public void run() {
    while(true){
      try{
        int delayTime = int(random(mmDelay[0],mmDelay[1]));  // Random Delay
        println("delay :",delayTime, "sec");
        Thread.sleep(delayTime);
      }catch(InterruptedException e){
        break;
      }
      if(MyMovies.size()<mmNum[1]){  // Compare with Max Movie Number
        MyMovie myMovie = YourMovies.remove(0);
        myMovie.refresh();
        MyMovies.add(myMovie);  // Add
        MovieTimer movieTimer = new MovieTimer(myMovie);
        movieTimer.setDaemon(true);
        movieTimer.start();
      }      
    }
  }
}

public class RemoveThread extends Thread{
  @Override
  public void run() {
    while(true){
      try{
        for(int i=0; i<MyMovies.size(); i++){  // Sequencially Search
          if(MyMovies.get(i).isStop){  // Movie end
            YourMovies.add(MyMovies.remove(i));
          }
        }
      Thread.sleep(1000);
      }catch(InterruptedException e){
        break;
      }
    }
  }
}

public class MovieTimer extends Thread{
  MyMovie myMovie;
  
  public MovieTimer(MyMovie myMovie){
    this.myMovie = myMovie;
  }
  
  @Override
  public void run() {
    try{
        int tmp = int(random(mmPlay[0],mmPlay[1]));
        println("play :",tmp,"sec");
        Thread.sleep(tmp);
    }catch(InterruptedException e){
    }
    if(myMovie.movie != null){
      myMovie.movie.stop();
      myMovie.isStop = true;
    }
  }
}
