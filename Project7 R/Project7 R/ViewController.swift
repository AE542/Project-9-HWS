//
//  ViewController.swift
//  Project7 R
//
//  Created by Mohammed Qureshi on 2020/08/13.
//  Copyright © 2020 Experiment1. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    var petitions = [Petition]()
    
    var filteredPetitions = [Petition]()
    
    var clearPetitions = [Petition]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Credits", style: .plain, target: self, action: #selector(petitionShow))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(filterResults))
        
        //performSelector(onMainThread: #selector(filterResults), with: nil, waitUntilDone: false)
    //this allows the filterResults func to work on a background thread. ERROR modifications to the layout enging must not be performed from a background thread after it has been accessed from the main thread.
        
        
        //performSelector(inBackground: #selector(fetchJSON), with: nil)//this means runs the fetchJSON method in the background
        
        
             let urlString: String
               if navigationController?.tabBarItem.tag == 0 {
                     urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
                } else {
                    urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
                    
                }
                
                DispatchQueue.global(qos: .userInitiated).async {
//                    //qos = quality of service
//                    //async = asynchronous - when calling async() we provide our work as a closure to handle it. - GCD makes sure that code executes on whichever thread is available.
                        [weak self] in// weak self we're using a closure here
                if let url = URL(string: urlString) {
                    if let data = try? Data(contentsOf: url) {
                        self?.parse(json: data)//must call self?. like this to allow the DispatchQueue to work // delete self?. as closure not used.
                        return
                        //alternatively could be written like this
                    }
                        //this is how we can prevent the UI from freezing up when getting data through JSON.
                        //NEVER GOOD TO DO UI WORK ON A BACKGROUND THREAD.
//                    }
//                   DispatchQueue.main.async { [weak self] in
//                        self?.showError()
                    }
                    DispatchQueue.main.async { [weak self] in
                    
                    self?.showError()
                        
                        //MAJOR ERROR took too long to solve. Using performSelector is good but the error the UINavigationControllertabBarItem must be used from the main thread only means its better to use the async() method as opposed to the performSelectorMethod here to avoid the error. Using Dispatch Queue.main.async is better to handle this data on a background thread.
                        
        }
        }
                    
                    
                    //showError()// this shows a UIAC and we shouldn't be using it in a background thread.
        //(onMainThread: #selector(showError), with: nil, waitUntilDone: false)// now we can run showError method on the main thread now so we can delete the DispatchQueue method below
                
               // this gets called regardless of the closure.
        
    }
    
    func parse(json: Data) {
        let decoder = JSONDecoder()
        DispatchQueue.global(qos: .userInitiated).async {
      
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
            self.petitions = jsonPetitions.results
            //tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)// removing this stopped the error being shown before that UI work cannot be done on background threads. Dispatch Queue pushes it back to the main thread.
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
            
            //error showing that UITableView must be used from the main thread only.
            //causes tableView to reload data on the main thread when load is finished.
            //you can use selector mehtods to point at methods from UIKit classes.
        }
        //else {
            //self.showError()
        }
            //performSelector(onMainThread: #selector(showError), with: nil, waitUntilDone: false)
//            DispatchQueue.main.async { [weak self] in// we have to do this on the MAIN background thread must be asynced. Closure capture is weak self then we add self?. to the tableView below.
//                self?.tableView.reloadData()
            
                
            }
    
    func filterResultsIn(_ answer: String){
        DispatchQueue.global(qos: .userInitiated) .async {
        
        var filteredPetitions = [Petition]()//THIS WAS THE MISSING PIECE. Make sure you put the variable inside the func so it avoids the unresolved identifier error.
            filteredPetitions = self.petitions.filter { $0.title.contains(answer) || $0.body.contains(answer)
            
        }
        
            self.petitions.removeAll(keepingCapacity: true)
            self.petitions += filteredPetitions
            
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return petitions.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let petition = petitions[indexPath.row]
        //index out of range error when trying to clear petitions.
        cell.textLabel?.text = petition.title
        cell.detailTextLabel?.text = petition.body
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            tableView.reloadData()
        }
        let vc = DetailViewController()
        vc.detailItem = petitions[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
     func showError() {
        DispatchQueue.main.async { [weak self] in
        let ac = UIAlertController(title: "Loading error", message: "There was a problem loading the feed; please check your connection and try again", preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(ac, animated: true)
        }
        
        }
    
    @objc func petitionShow() {//
        let ac = UIAlertController(title: "This data comes from the We the people API of the White House.", message: "https://www.hackingwithswift.com/samples/petitions-1.json", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                present(ac, animated: true)
                    }
     @objc func filterResults() {
        let ac = UIAlertController(title: "Filter Results", message: "Please type your search in below.", preferredStyle: .alert)
        ac.addTextField()
        DispatchQueue.global(qos: .userInitiated) .async {
            
        let submitFilter = UIAlertAction(title: "Submit", style: .default) {
            [weak self, weak ac] action in
            guard let answer = ac?.textFields?[0].text
                else { return }
            self?.filterResultsIn(answer)
           
            }
            
        DispatchQueue.global (qos: .userInteractive).async {
            
        let clearAll = UIAlertAction (title: "Clear", style: .default) {
            
            [weak self] action in
            self?.petitions.removeAll(keepingCapacity: true)
            
            self?.petitions += self!.clearPetitions
            
            //self?.petitions.append(contentsOf: self!.petitions)// this cleared the petition but didn't load it again.
            
        
              
            //            DispatchQueue.main.async { [weak self] in
            //            self?.tableView.reloadData()
        }
            DispatchQueue.main.async { [weak self] in
        ac.addAction(submitFilter)
        ac.addAction(clearAll)
        
        self?.present(ac, animated: true)
            }
    }
            
    

}


}
}
