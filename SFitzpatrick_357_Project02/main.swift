//
//  main.swift
//  SFitzpatrick_357_Project02
//
//  Created by Scott Fitzpatrick on 2/25/21.
//

import Foundation


/* Read JSON file and insantiate a dictionary with the data */
let passphrase = "temp"
var fileName = "mybadpasswords.json"
var mainDictionary = readJSONfileTo(fileName: fileName)
var userInput = "" //prepare userInput var for loop


/* Program loop */
while (userInput != "exit") {
    /* Prompt user for command and get input. Check if valid input. */
    print("\nPlease enter \"va\" to view all password keys, \"vs\" to view a single password, \"d\"")
    print("to delete a password, and \"as\" to add a single password. Or type \"exit\" to exit:")
    userInput = readLine()!

    /* Check if input is a valid command; if not, re-prompt and input */
    while ((userInput != "va") && (userInput != "vs") && (userInput != "d") && (userInput != "as") && (userInput != "exit")) {
        print("Invalid input. Please try again:")
        userInput = readLine()!
    }

    /* Run program depending on user input */
    if (userInput == "va") { // Print keys
        viewAll()
    }
    else if (userInput == "vs") { // Print single password
        viewSingle()
    }
    else if (userInput == "d") { // Delete single password
        deleteSingle()
    }
    else if (userInput == "as") { // Add single password
        addSingle()
    }
    else { // Exit program
        print("Exiting...")
        exit(0)
    }
}



/* Read and write JSON Functions*/
func readJSONfileTo(fileName: String)->[String:String] {
    var returnDict: [String:String] = [:]
    
    do {
        let fileURL = try FileManager.default.url(for:.applicationSupportDirectory, in:.userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("mybadpasswords.json")
            
        /* Convert JSON file to string and save data to dicionary temp */
        let myStr = try String(contentsOf: fileURL, encoding: .utf8)
        let data = myStr.data(using: .utf8)
        let dictionaryTemp = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
        
        /* Put contents of JSON file into mainDictionary */
        for (key,value) in dictionaryTemp {
            returnDict[key] = value as? String
        }
    } catch {
        print(error)
    }
    return returnDict
}

func writeToJSONfile(dict: [String:String]) {
    do {
    let fileURL = try FileManager.default.url(for: .applicationSupportDirectory, in:.userDomainMask, appropriateFor: nil, create: true) //if not there, create it
        .appendingPathComponent("mybadpasswords.json")

    try JSONSerialization.data(withJSONObject: mainDictionary).write(to:  fileURL) //write
        
    } catch {
        print(error)
    }
}



/* Edit Dictionary Functions */
func viewAll() {
    print("\nDictionary Keys:")
    
    /* Loop through dictionary keys & print */
    for (key) in mainDictionary.keys {
        print("  ", "\(key)")
    }
}

func viewSingle() {
    print("Please enter a corresponding key:")
    let keyInput = readLine()
    
    /* If key doesn't exist, exit */
    if (mainDictionary[keyInput ?? "<no_name>"] == nil) {
        print("No key found. Please return to the main menu.")
        exit(0)
    }
    
    /* Prompt & input passphrase */
    print("Please enter your passphrase:")
    let ppInput = readLine()
    
    /* If coorect, descramble password and print */
    if (ppInput == passphrase) {
        print(keyInput!, "password:", descramble(scrambledStr: mainDictionary[keyInput!]!))
    }
}

func deleteSingle() {
    print("Please enter the key of the password you want to delete:")
    let deleteKey = readLine()
    
    /* If key doesn't exist, exit */
    if (mainDictionary[deleteKey ?? "<no_name>"] == nil) {
        print("No key found. Please return to main menu.")
        exit(0)
    }
    
    /* Remove key & password and update file */
    mainDictionary.removeValue(forKey: deleteKey!)
    writeToJSONfile(dict: mainDictionary)
}

func addSingle() {
    /* Prompt & input keyInput, passwordInput, and passphrase */
    print("Please enter the desired key name for the password:")
    let keyInput = readLine()
    print("Please enter your desired password (lowercase):")
    let passwordInput = readLine()
    print("Please enter your passphrase:")
    let ppInput = readLine()
    
    /* Initialize unscrambledPW like: passwordPassphrase; then scramble it
     and add to dictionary. Lastly, update the JSON file */
    let unscrambledPW = (passwordInput! + ppInput!)
    mainDictionary[keyInput!] = scramble(unscrambledPW: unscrambledPW)
    writeToJSONfile(dict: mainDictionary) //update file
}

func scramble(unscrambledPW: String) -> (String) {
    /* Make passwordPassphrase backwards */
    let backwardsPW = String(unscrambledPW.reversed())
    
    /* Return the caesar ciphered backwardsPW */
    return caesarCipher(value: backwardsPW, shift: 3)
}

func descramble(scrambledStr: String) -> String {
    var decodedPW = ""
    
    /* Shift the caesarCipher so the letters are normal again,
     and the reverse it again to form passwordPassphrase */
    decodedPW = caesarCipher(value: scrambledStr, shift: -3)
    decodedPW = String(decodedPW.reversed())
    
    /* If the passwordPassphrase contains the proper passphrase,
     return the decoded password. Otherwise return error */
    if decodedPW.contains(passphrase) {
        return String(decodedPW.dropLast(passphrase.count))
    }
    else {
        return "Error: Could not retrieve the password."
    }
}

func caesarCipher(value: String, shift: Int) -> String {
    var cipheredPW = [Character]() //make empty char array

    /* For each char in value string */
    for i in value.utf8 {
        let shiftedUTFval = Int(i) + shift //initialize shiftedUTFval

        // See if value exceeds Z.
        // ... The Z is 26 past "A" which is 97.
        // ... If greater than "Z," shift backwards 26.
        // ... If less than "A," shift forward 26.
        
        /* If out of UTF alphabet boundaries do magic, if in boundaries (else)
         Append the ciphered char to cipheredPW. */
        if shiftedUTFval > 122 { //if more than UTF lowercase boundaries
            cipheredPW.append(Character(UnicodeScalar(shiftedUTFval - 26)!))
        } else if shiftedUTFval < 97 { //if less than UTF lowercase boundaries
            cipheredPW.append(Character(UnicodeScalar(shiftedUTFval + 26)!))
        } else {
            cipheredPW.append(Character(UnicodeScalar(shiftedUTFval)!))
        }
    }
    return String(cipheredPW)
}
