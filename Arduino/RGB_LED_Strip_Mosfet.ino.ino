#define RED       5// pin for red LED
#define GREEN    3 // pin for green - never explicitly referenced
#define BLUE     6 // pin for blue - never explicitly referenced


const int ledpin = 12; //output pin


long k, temp_value;
char rx_byte;
void setup () {
  //baud rate
  Serial.begin(9600);
  //change pinmode to output
  pinMode(ledpin, OUTPUT);
  //make all three pins output pins for pwd
  for (k=0; k<3; k++) {
    pinMode(RED , OUTPUT);
    pinMode(GREEN, OUTPUT);
    pinMode(BLUE, OUTPUT);

  }
}

//continuously run
void loop() {
  //if arduino is correctly connected
  if(Serial.available()>0){
    //read from serial
    rx_byte = Serial.read();
    //if integer received is 1
    if(rx_byte == 1)
    {
      //write Yellow color
      digitalWrite(ledpin, HIGH);
   
        analogWrite(RED, 250);
        
        analogWrite(BLUE, 0);

        analogWrite(GREEN, 50);
        
        
    }
    //if integer recieved is 2 
    if(rx_byte == 2){
      digitalWrite(ledpin,LOW);
        //write Green color
        analogWrite(RED, 0);
        
        analogWrite(BLUE, 0);

        analogWrite(GREEN, 255);
       
   }

    //if integer received is 3
    if(rx_byte == 3){
      //write Red color
      digitalWrite(ledpin,LOW);
   
        analogWrite(RED, 255);
        
        analogWrite(BLUE, 0);

        analogWrite(GREEN, 0);
       
   }

    //if integer received is 4
    if(rx_byte == 4){
      //write Blue color
      digitalWrite(ledpin,LOW);
      
        analogWrite(RED, 0);
        
        analogWrite(BLUE, 255);

        analogWrite(GREEN, 0);
       
   }
    //if integer received is 5 
    if(rx_byte == 5){
      //write no color
      digitalWrite(ledpin,LOW);
 
        analogWrite(RED, 0);
        
        analogWrite(BLUE, 0);

        analogWrite(GREEN, 0);
        

   }
     
  }
     
}

