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

class ViewController: JSQMessagesViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    var imagePicker = UIImagePickerController()
    var messages = [JSQMessage]()
    override func viewDidLoad() {
        super.viewDidLoad()
        senderId = "1"
        senderDisplayName = "hlt"
        

        
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
    
    // Message colour settings
    lazy var outgoingBubble : JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleGreen())
    }()
    
    lazy var incominggoingBubble : JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }()
    
    
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
//        let ref = Constants.dbRef.childByAutoId()  // Uniqe id
//        let message = ["senderId" : senderId , "sendername" : senderDisplayName , "message" : text]
//        ref.setValue(message)
        
        self.messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text))
        collectionView.reloadData()
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
            let JSQImage = JSQPhotoMediaItem(image : selectedImage)
            self.messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, media: JSQImage))
        }else if let selectedVideo = info[UIImagePickerControllerMediaURL] as? URL {
            let JSQVideo = JSQVideoMediaItem(fileURL: selectedVideo, isReadyToPlay: true)
            self.messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, media: JSQVideo))
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
    
}

