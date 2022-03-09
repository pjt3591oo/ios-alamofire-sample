//
//  ViewController.swift
//  serverComunicationSample
//
//  Created by 박정태 on 2022/03/09.
//

import UIKit
import Alamofire
import Photos

class ViewController: UIViewController {
    let imagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePickerController.delegate = self
    }

    @IBAction func onClickGetBtn(_ sender: Any) {
        AF
            .request(
                "http://localhost:3000/user",
                method: .get,
                parameters: ["a":1], // query string
                encoding: URLEncoding.default,
                headers: ["Content-Type":"application/json", "Accept":"application/json"]
            )
            .validate(statusCode: 200..<300)
            .responseJSON { (response) in
                print(response)
            }
    }
    
    
    @IBAction func onClickPostBtn(_ sender: Any) {
        AF
            .request(
                "http://localhost:3000/user",
                method: .post,
                parameters: ["name":"mung1", "age": 30],
                encoding: JSONEncoding.default,
                headers: ["Content-Type":"multipart/form-data", "Accept":"application/json"]
            )
            .validate(statusCode: 200..<300)
            .responseJSON { (response) in
                print(response)
            }
    }
    
    @IBAction func onClickUploadBtn(_ sender: Any) {
        let url = NSURL(string: "https://lh3.googleusercontent.com/ogw/ADea4I7GOM3jFhU3s4x6-QoqDxPVZRwdSK0aV6Qy3DO7=s32-c-mo")
        let data = NSData(contentsOf: url! as URL)
        
        if let data = NSData(contentsOf: url! as URL) {
            let image: UIImage? = UIImage(data: data as Data)
            if let data = image?.pngData() {
                AF.upload(
                    multipartFormData: {multiPart in
                        multiPart.append(data , withName: "file", fileName: "test_logo.png", mimeType: "image/jpeg")
                    },
                    to: "http://localhost:3000/file"
                )
                .validate(statusCode: 200..<300)
                .uploadProgress(queue: .main, closure: { progress in
                                //Current upload progress of file
                                print("Upload Progress: \(progress.fractionCompleted)")
                            })
                .responseJSON { (response) in
                    print(response)
                }
            }
        }
    }
    
    @IBAction func onClickAlbumByBtn(_ sender: Any) {
        self.checkAlbumPermission()
    }
    
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            if let data = image.pngData() {
                AF.upload(
                    multipartFormData: {multiPart in
                        multiPart.append(data , withName: "file", fileName: "test_logo.png", mimeType: "image/jpeg")
                    },
                    to: "http://localhost:3000/file"
                )
                .validate(statusCode: 200..<300)
                .uploadProgress(queue: .main, closure: { progress in
                    if progress.fractionCompleted < 1.0 {
                        print("업로드 중: \(progress.fractionCompleted)")
                    } else {
                        print("업로드 완료")
                    }
                })
                .responseJSON { (response) in
                    print(response)
                }
            }
        }
        dismiss(animated: true, completion: nil)
    }
    func checkAlbumPermission(){
        /*
             notDetermined : 아직 접근 여부를 결정하지 않은 상태
             restricted : 앨범에 접근 불가능하고, 권한 변경이 불가능한 상태
             denied : 앨범 접근 불가능한 상태. 권한 변경이 가능함.
             authorized : 앨범 접근이 승인된 상태.
         */
        PHPhotoLibrary.requestAuthorization( { status in
            switch status{
            case .authorized:
                print("Album: 권한 허용")
                if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                    // 앨범오픈
                    DispatchQueue.main.async {
                        self.imagePickerController.sourceType = .photoLibrary;
                        self.imagePickerController.allowsEditing = true
                        self.present(self.imagePickerController, animated: true, completion: nil)
                    }
                }
            case .denied:
                print("Album: 권한 거부")
            case .restricted, .notDetermined:
                print("Album: 선택하지 않음")
            default:
                break
            }
        })
    }
}
