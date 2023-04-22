//
//  MainView.swift
//  reactApp
//
//  Created by Mohamed Mataam on 22/04/2023.
//

import SwiftUI
import AVFoundation

struct MainView: View {
    var inPreview = false
    
    var tabs = ["bubble.left", "camera", "gearshape"]
    
    @GestureState private var scrollOffset : CGFloat = 0
    @State private var currentIndex : Int = 1
    
    var body: some View {
        ZStack{
            GeometryReader{geo in
                VStack {
                    HStack(spacing: 0){
                        ZStack{
                            Rectangle().fill(.red)
                            Text("View 1").font(.system(size: 64))
                        }
                        .zIndex(1)
                        .id(1)
                        
                        GeometryReader{geoView in
                            CameraView(inPreview: inPreview)
                            .offset(x: -geoView.frame(in: .global).minX)
                        }
                        
                        ZStack{
                            Rectangle().fill(.green)
                            Text("View 3").font(.system(size: 64))
                        }
                        .zIndex(1)
                    }
                    .offset(x: max(min(0, (-geo.size.width * CGFloat(currentIndex)) + scrollOffset), -geo.size.width * CGFloat(tabs.count - 1)))
                    .frame(width: geo.size.width*CGFloat(tabs.count))
                    .gesture(DragGesture().updating($scrollOffset, body: { value, out, _ in
                            out = value.translation.width
                    }).onEnded({ val in
                        let offsetX = max(-geo.size.width,min(val.predictedEndTranslation.width, geo.size.width))
                        let progress = -offsetX / geo.size.width
                        let roundProgress = progress.rounded()
                        
                        currentIndex = max(0, min(currentIndex + Int(roundProgress), tabs.count - 1))
                    }))
                }
            }.animation(.easeOut, value: scrollOffset == 0)
            
            VStack{
                Spacer()
                ZStack{
                    Rectangle()
                        .fill(Color(hex: 0x1c1c1c))
                        .frame(height: 100)
                        .clipShape(RoundedCorner(cornerRadius: 30, corners: [.topLeft, .topRight]))
                    
                    HStack{
                        Spacer()
                        
                        
                        ForEach(
                            Array(
                                tabs.enumerated()
                            ),
                            id: \.offset)
                        { index, element in
                            
                            Button {
                                withAnimation {
                                    currentIndex = index
                                }
                            } label: {
                                Image(systemName: element)
                            }
                            
                            Spacer()
                        }
                        
                    }.padding(.bottom, 32)
                }
            }
        }.ignoresSafeArea()
    }
}

struct CameraView: View {
    @State private var isRecording = false
    @State private var tookPicture = false
    
    var inPreview = false
    
    @StateObject var camera = CameraModel()
    var body: some View{
        ZStack{
            if(!inPreview){
                CameraPreview(camera: camera)
                    .ignoresSafeArea(.all, edges: .all)
                    .onTapGesture(count: 2) {
                        camera.flipCam()
                    }
            }else{
                Color.black.ignoresSafeArea(.all, edges: .all)
            }
            
            VStack{
                HStack{
                    Spacer()
                    
                    Button(action: {
                        camera.flipCam()
                    }, label: {
                        Image(systemName: "arrow.triangle.2.circlepath.camera")
                            .foregroundColor(.white)
                            .font(.system(size: 32))
                    }).frame(width: 100, height: 100)
                }
                
                Spacer()
                
                HStack{
                    if camera.isTaken{
                        Button(action: {camera.isTaken.toggle()}, label: {
                            Text("Save")
                                .foregroundColor(.black)
                                .fontWeight(.semibold)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .background(Color.white)
                                .clipShape(Capsule())
                        })
                        .padding(.leading, 10)
                        
                        Spacer()
                    }
                    else{
                        ZStack{
                            Circle()
                                .fill(self.isRecording ? .red : .white)
                                .frame(width: 65, height: 65)
                                .simultaneousGesture(
                                    DragGesture(minimumDistance: 0)
                                        .onEnded({_ in
                                            if(self.isRecording){
                                                self.isRecording = false
                                            }else{
                                                self.camera.isTaken.toggle()
                                            }
                                        })
                                )
                                .simultaneousGesture(
                                    LongPressGesture(minimumDuration: 0.25)
                                        .onEnded({_ in
                                            self.isRecording = true
                                        })
                                )
                            
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                                .frame(width: 75)
                        }
                    }
                }
                .frame(height: 300)
            }
        }
        .onAppear(perform: {
            camera.Check()
        })
    }
}

class CameraModel: ObservableObject{
    @Published var isTaken = false
    @Published var session = AVCaptureSession()
    @Published var alert = false
    @Published var output = AVCapturePhotoOutput()
    @Published var preview : AVCaptureVideoPreviewLayer!
    
    private var backCam = true
    
    private var frontCamDevice: AVCaptureDevice?
    private var backCamDevice: AVCaptureDevice?
    
    func flipCam(){
        do {
            var videoInput: AVCaptureDeviceInput?
            if(backCam){
                videoInput = try AVCaptureDeviceInput(device: frontCamDevice!)
            }else{
                videoInput = try AVCaptureDeviceInput(device: backCamDevice!)
            }
            self.backCam.toggle()
            
            self.session.beginConfiguration()
            self.session.removeInput(self.session.inputs.first!)
            
            self.session.addInput(videoInput!)
            
            self.session.commitConfiguration()
        } catch {
            print("Erreur lors de la configuration de l'entrée vidéo : \(error.localizedDescription)")
        }
    }
    
    func Check(){
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setUp()
            return
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) {
                (status) in
                
                if(status){
                    self.setUp()
                }
            }
        case .denied:
            self.alert.toggle()
            return
        default:
            return
        }
    }
    
    func setUp(){
        
        do{
            self.session.beginConfiguration()
            
            let deviceTypes: [AVCaptureDevice.DeviceType] = [
                .builtInDualCamera,
                .builtInDualWideCamera,
                .builtInLiDARDepthCamera,
                .builtInTelephotoCamera,
                .builtInTripleCamera,
                .builtInTrueDepthCamera,
                .builtInUltraWideCamera,
                .builtInWideAngleCamera
            ]
            
            let frontDevices = AVCaptureDevice.DiscoverySession(
                deviceTypes: deviceTypes,
                mediaType: .video,
                position: .front)
                .devices
            
            let backDevices = AVCaptureDevice.DiscoverySession(
                deviceTypes: deviceTypes,
                mediaType: .video,
                position: .back)
                .devices
            
            guard let frontCamera = frontDevices.first else { return }
            //guard let backCamera = backDevices.last else { return }
            guard let backCamera = AVCaptureDevice.default(for: .video) else { return }
            frontCamDevice = frontCamera
            backCamDevice = backCamera
            
            let input = try AVCaptureDeviceInput(device: backCamera)
            
            if self.session.canAddInput(input){
                self.session.addInput(input)
            }
            
            if self.session.canAddOutput(self.output){
                self.session.addOutput(self.output)
            }
            
            self.session.commitConfiguration()
        }
        catch{
            print(error.localizedDescription)
        }
    }
}

struct CameraPreview: UIViewRepresentable{
    @ObservedObject var camera: CameraModel
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        
        camera.preview = AVCaptureVideoPreviewLayer(session: camera.session)
        camera.preview.frame = view.frame
        
        camera.preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(camera.preview)
        
        camera.session.startRunning()
        
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}
