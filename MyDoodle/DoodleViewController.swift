//
//  DoodleViewController.swift
//  MyDoodle
//
//  Created by Mohd Imran on 6/22/17.
//  Copyright © 2017 Mohd Imran. All rights reserved.
//

import UIKit


class DoodleViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,DoodlePadProtocol, UICollectionViewDelegate, UICollectionViewDataSource {

    //MARK: - IBOutles
    
    @IBOutlet weak var colorsView: UIView!
    @IBOutlet weak var lineWidthView: UIView!
    @IBOutlet weak var lineWidthLabel: UILabel!
    @IBOutlet weak var lineWidthMinusButton: UIButton!
    @IBOutlet weak var lineWidthPlusButton: UIButton!
    @IBOutlet weak var colorCollectionView: UICollectionView!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var clearImageButton: UIButton!
    @IBOutlet weak var shareImageButton: UIButton!
    
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var doodlePad: DoodlePad!
    
    //MARK: - Lazy Objects
    
    lazy var dataSourceColor: Array<[String:AnyObject]> = {
        var arrayColor = [["color":UIColor.red, "isSelected":NSNumber(booleanLiteral: false)], ["color":UIColor.green, "isSelected":NSNumber(booleanLiteral: false)], ["color":UIColor.brown, "isSelected":NSNumber(booleanLiteral: false)], ["color":UIColor.blue, "isSelected":NSNumber(booleanLiteral: false)], ["color":UIColor.black, "isSelected":NSNumber(booleanLiteral: false)], ["color":UIColor.cyan, "isSelected":NSNumber(booleanLiteral: false)], ["color":UIColor.gray, "isSelected":NSNumber(booleanLiteral: false)],["color":UIColor.magenta, "isSelected":NSNumber(booleanLiteral: true)], ["color":UIColor.yellow, "isSelected":NSNumber(booleanLiteral: false)],["color":UIColor.purple, "isSelected":NSNumber(booleanLiteral: false)]]
        return arrayColor
    }()
    
    //MARK: - UIViewController Delegates
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doodlePad.layer.cornerRadius = 5
        doodlePad.clipsToBounds = true
        
        colorsView.layer.cornerRadius = 5
        colorsView.clipsToBounds = true
        
        lineWidthView.layer.cornerRadius = 5
        lineWidthView.clipsToBounds = true
        
        photoButton.layer.cornerRadius = photoButton.frame.size.width/2
        photoButton.layer.borderColor  = UIColor.blue.cgColor
        photoButton.layer.borderWidth  = 1.0
        
        lineWidthLabel.text = String(format: "%.f", doodlePad.drawingLineWidth)
        
        doodlePad.delegate = self
        
        assignDefaultColortoDoodlePad()
        
        let request = NetworkRequest(withURL: "http://localhost/api/api.php", withHttpMethd: .GET)
        NetworkManager().startAPIRequest(with: request.objURLRequest, callBack: {(apiData:Any?, response:URLResponse?, error:Error?)->Void in
        
            print("This is Data: ",apiData)
            
        })
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        
        doodlePad.image = nil
    }
    
    //MAKR: - IBActions
    
    @IBAction func decreaseLineWidth(_ sender: Any) {
        
        guard var value = (lineWidthLabel.text as NSString?)?.intValue, value > 1 else {
            return
        }
        value = value - 1
        lineWidthLabel.text = String(format: "%d", value)
        doodlePad.drawingLineWidth = CGFloat(value)
    }
    
    @IBAction func increaseLineWidth(_ sender: Any) {
        
        guard var value = (lineWidthLabel.text as NSString?)?.intValue else {
            return
        }
        
        value = value + 1
        lineWidthLabel.text = String(format: "%d", value)
        doodlePad.drawingLineWidth = CGFloat(value)
    }
    
    @IBAction func takePhoto(_ sender: Any) {
    
        weak var weakSelf = self
        
        let alertVC = UIAlertController(title: "Photo", message: "Please choose source", preferredStyle: .actionSheet)
        let cameraAlertAction = UIAlertAction(title: "Camera", style: .default, handler: {(alertAction)->Void in
        
            weakSelf?.onPhotoAction(.camera, sender)
        })
        let photoAlertAction = UIAlertAction(title: "Photo", style: .default, handler: {(alertAction)->Void in
            weakSelf?.onPhotoAction(.photoLibrary, sender)
        })
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {(alertAction)->Void in
            
        })
        
        
        alertVC.addAction(cameraAlertAction)
        alertVC.addAction(photoAlertAction)
        alertVC.addAction(cancelAlertAction)
        present(alertVC, animated: true, completion: {
        
        })
        if UIDevice.current.userInterfaceIdiom == .pad{
        
            alertVC.popoverPresentationController?.sourceView = sender as? UIButton
            
        }
        
    }
    
    @IBAction func shareImage(_ sender: Any) {
        
        if let img = doodlePad.image{
         
            let imageToShare = [ img ]
            let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
            
            // exclude some activity types from the list (optional)
            //activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]
            
            // present the view controller
            self.present(activityViewController, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func clearImage(_ sender: Any) {
        
        doodlePad.image = nil
        photoButton.isHidden = false
    }
    
    @IBAction func saveImage(_ sender: Any) {
        
        guard let img = doodlePad.image else {
            
            let alertVC = UIAlertController(title: "Please draw something", message: nil, preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {(alertAction)->Void in
            
            })
            alertVC.addAction(alertAction)
            present(alertVC, animated: true, completion: {
            
            })
            return
        }
        
        let documentsDirPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        print("Path: ",documentsDirPath.relativePath.appending("/doodle.png"))
        
        do {
            let _ = try UIImagePNGRepresentation(img)?.write(to: documentsDirPath.appendingPathComponent("doodle.png"))
            let alertVC = UIAlertController(title: "Drawing has been saved successfully.", message: nil, preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {(alertAction)->Void in
                
            })
            alertVC.addAction(alertAction)
            present(alertVC, animated: true, completion: {
                
            })
        }catch let error {
            print("Error: ",error)
        }
    }
    
    //MARK: - UIViewContoller Methods
    
    func onPhotoAction(_ alertActionType:UIImagePickerControllerSourceType, _ sender:Any) -> Void {
        
        if UIImagePickerControllerSourceType(rawValue: alertActionType.rawValue) == UIImagePickerControllerSourceType.camera{
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) == false{
                
                let alert = UIAlertController(title: "Camera not found on this Device", message: nil, preferredStyle: .alert)
                let actionButton = UIAlertAction(title: "Cancel", style: .cancel, handler: {(action)->Void in
                    
                })
                alert.addAction(actionButton)
                present(alert, animated: true, completion: {
                })
                return
            }
        }
        
        let pickerController = UIImagePickerController()
        pickerController.allowsEditing = false
        pickerController.sourceType = UIImagePickerControllerSourceType(rawValue: alertActionType.rawValue)!
        pickerController.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        pickerController.delegate = self
        
        if UIDevice.current.userInterfaceIdiom == .pad{
            pickerController.modalPresentationStyle = .popover
            present(pickerController, animated: true, completion: nil)
            pickerController.popoverPresentationController?.barButtonItem = UIBarButtonItem(customView: (sender as! UIButton).superview!)
        }else{
            present(pickerController, animated: true, completion: {
                
                
                
                
            })
        }
    }
    
    func assignDefaultColortoDoodlePad() -> Void {
        
        for (_, dic) in dataSourceColor.enumerated() {
            
            if let value = dic["isSelected"] as? NSNumber, value.boolValue == true {
                doodlePad.drawingLineColor = dic["color"] as! UIColor
            }
        }
    }
    
    //MARK: - UIImagePickerControllerDelegate,UINavigationControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            doodlePad.image = image
            dismiss(animated: true, completion: nil)
            photoButton.isHidden = true
        }
    }
    
    //MARK: - DoodlePadProtocol
    
    func drawingStart() {
        photoButton.isHidden = true
    }
    
    //MARK: - UICollectionView Deleagate and DataSource
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellIdentifier:String = "colorCell"
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? ColorCollectionViewCell else {
            
            return UICollectionViewCell()
            
        }
        
        cell.cellView.backgroundColor = dataSourceColor[indexPath.row]["color"] as? UIColor
        if ((dataSourceColor[indexPath.row]["isSelected"] as? Bool) == true){
            cell.cellView.layer.borderColor =  UIColor.white.cgColor
            cell.cellView.layer.borderWidth =  2.5
        }else{
            cell.cellView.layer.borderColor =  UIColor.clear.cgColor
            cell.cellView.layer.borderWidth =  0
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSourceColor.count
    }
    

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        doodlePad.drawingLineColor = dataSourceColor[indexPath.row]["color"] as! UIColor
        
        for (idx, var dic) in dataSourceColor.enumerated() {
            
            if let value = dic["isSelected"] as? NSNumber, value.boolValue == true {
                dic["isSelected"] = NSNumber(booleanLiteral: false)
                dataSourceColor[idx] = dic
            }
        }
        
        dataSourceColor[indexPath.row]["isSelected"] = NSNumber(booleanLiteral: true)
        collectionView.reloadData()
    }
    
}
