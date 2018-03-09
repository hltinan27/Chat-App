//
//  ViewController.swift
//  Chat App
//
//  Created by inan on 7.03.2018.
//  Copyright © 2018 inan. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import MobileCoreServices
import AVKit
import SDWebImage

class ViewController: JSQMessagesViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    var imagePicker = UIImagePickerController()
    var messages = [JSQMessage]()
    
    // Message colour settings
    lazy var outgoingBubble : JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleGreen())
    }()
    
    lazy var incominggoingBubble : JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        senderId = "2"
        senderDisplayName = "halit"
        
        let lastMessages = Constants.dbChats.queryLimited(toLast: 20)
        lastMessages.observe(.childAdded) { (snapshot) in
            if let data = snapshot.value as? [String : String] ,
                let senderId = data["senderId"],
                let displayName = data["sendername"],
                let text = data["message"],
                !text.isEmpty{
                if let message = JSQMessage(senderId: senderId, displayName: displayName, text: text){
                    self.messages.append(message)
                    self.finishReceivingMessage()
                   
                }
                
            }
        }
        
        let lastMediaMessages = Constants.dbmedias.queryLimited(toLast: 20)
        lastMediaMessages.observe(.childAdded) { (snapshot) in
            if let data = snapshot.value as? [String : String] ,
                let senderId = data["senderId"],
                let displayName = data["senderName"],
                let url = data["url"],
                !url.isEmpty{
                if let mediaURL = URL(string : url) {
               
                do{
                    let data = try Data(contentsOf : mediaURL)
                    if let convertImage = UIImage(data: data){
                        let imageDownload = SDWebImageDownloader.shared().downloadImage(with: mediaURL, options: [], progress: nil, completed: { (image, data, error, finish) in
                            DispatchQueue.main.async {
                                let photo = JSQPhotoMediaItem(image : image)
                                if senderId == senderId {
                                    photo?.appliesMediaViewMaskAsOutgoing = true
                                }else {
                                    photo?.appliesMediaViewMaskAsOutgoing = false
                                }
                                self.messages.append(JSQMessage(senderId: senderId, displayName: displayName, media: photo))
                                self.collectionView.reloadData()
                            }
                        })
                    }else{
                        let video = JSQVideoMediaItem(fileURL: mediaURL, isReadyToPlay: true)
                        if senderId == senderId {
                            video?.appliesMediaViewMaskAsOutgoing = true
                        }else {
                            video?.appliesMediaViewMaskAsOutgoing = false
                        }
                        self.messages.append(JSQMessage(senderId: senderId, displayName: displayName, media: video))
                    }
                    
                }catch{
                    
                }
                }
            }
        }
        
        // attach hidden
//        inputToolbar.contentView.leftBarButtonItem = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
        
    }
    
   
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        return messages[indexPath.item].senderId == senderId ? outgoingBubble : incominggoingBubble
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    // inMessage TabLabel
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        return messages[indexPath.item].senderId == senderId ? nil : NSAttributedString(string : messages[indexPath.item].senderDisplayName)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return messages[indexPath.item].senderId == senderId ? 0 : 20
    }
    
    // didPress SEND BUTTON
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let ref = Constants.dbChats.childByAutoId() // Uniqe id
        let message = ["senderId" : senderId , "sendername" : senderDisplayName , "message" : text]
        
        //self.messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text))
        collectionView.reloadData()
        //SAVE MESSAGE
        ref.setValue(message)
        
        finishSendingMessage()
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        let actionSheet = UIAlertController(title: "Image", message: "Please Select Image", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let image = UIAlertAction(title: "Images", style: UIAlertActionStyle.default) { (action) in
            
            selectSourceType(type: kUTTypeImage)
            
        }
        
        let camera = UIAlertAction(title: "Camera", style: UIAlertActionStyle.default) { (action) in
            
            selectSourceType(type: kUTTypeMovie)
            
        }
        let video = UIAlertAction(title: "Video", style: .default) { (action) in
            self.imagePicker.delegate = self
            
        }
        
        func selectSourceType(type : NSString){
            self.imagePicker.delegate = self
            self.imagePicker.mediaTypes = [type as String]
            self.present(self.imagePicker, animated: true, completion: nil)
            
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        
        actionSheet.addAction(image)
        actionSheet.addAction(camera)
        actionSheet.addAction(cancel)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    // Image Selected Settings
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
//            let JSQImage = JSQPhotoMediaItem(image : selectedImage)
//            self.messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, media: JSQImage))
            let data = UIImageJPEGRepresentation(selectedImage, 0.5)
            senderImageMessage(image: data, video: nil, senderId: senderId, senderName: senderDisplayName)
        }else if let selectedVideo = info[UIImagePickerControllerMediaURL] as? URL {
//            let JSQVideo = JSQVideoMediaItem(fileURL: selectedVideo, isReadyToPlay: true)
//            self.messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, media: JSQVideo))
            senderImageMessage(image: nil, video: selectedVideo, senderId: senderId, senderName: senderDisplayName)
        }
        dismiss(animated: true, completion: nil)
        collectionView.reloadData()
    }
    
    //Play Video
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        let message = messages[indexPath.item]
        if message.isMediaMessage{
            if let videoMessage = message.media as? JSQVideoMediaItem {
                let player = AVPlayer(url: videoMessage.fileURL)
                let playerController = AVPlayerViewController()
                playerController.player = player
                present(playerController, animated: true, completion: nil)
                
            }
        }
    }
    
    func saveImageMessage(senderId : String , senderName : String , url : String){
        
        let data = ["senderId" : senderId , "senderName" : senderName , "url": url ]
        print("Data \(data)")
        Constants.dbmedias.childByAutoId().setValue(data)
    }
    
    func senderImageMessage(image : Data? , video : URL?, senderId : String, senderName : String){
        
        if image != nil {
            Constants.imageStorageRef.child(senderId + "\(NSUUID().uuidString).jpg").putData(image!, metadata: nil) { (metadata, error) in
                guard let metadata = metadata else {
                    print(error?.localizedDescription)
                    return
                }
                let downloadURL = metadata.downloadURL
                self.saveImageMessage(senderId: senderId, senderName: senderName, url: String(describing : metadata.downloadURL()!))
                // Metadata contains file metadata such as size, content-type, and download URL.
                
                print("Download URL \(downloadURL)")
            }
        }else {
            Constants.videosStorageRef.child(senderId + "\(NSUUID().uuidString)").putFile(from: video!, metadata: nil) { (metadata, error) in
                guard let metadata = metadata else {
                    print(error?.localizedDescription)
                    return
                }
                // Metadata contains file metadata such as size, content-type, and download URL.
                let downloadURL = metadata.downloadURL
                self.saveImageMessage(senderId: senderId, senderName: senderName, url: String(describing : metadata.downloadURL()!))
                print("Download URL \(downloadURL)")
            }
            
        }
    }
    
}

