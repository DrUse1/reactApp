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
    
    // Initialiser les 3 tabs (et leurs icones)
    var tabs = ["bubble.left", "camera", "gearshape"]
    
    @GestureState private var scrollOffset : CGFloat = 0
    @State private var currentIndex : Int = 1
    
    var body: some View {
        // La vue sera composé de la nav et du reste derrière
        ZStack{
            // Le GeometryReader permet de connaitre la position/taille de l'élement qu'il englobe à l'écran
            GeometryReader{geo in
                // Le HStack sera composé des 3 tabs : les uns à coté des autres
                HStack(spacing: 0){
                    // Premier tab // TODO
                    Conversations()
                    .zIndex(1)
                    
                    // Deuxième tab : caméra, le geometryReader permet d'avoir l'effet "fixe" du tab, à chaque fois que la tab bouge, elle subit un offset opposé à ce mouvement et donc reste "fixe"
                    GeometryReader{geoView in
                        CameraView(inPreview: inPreview)
                            .offset(x: -geoView.frame(in: .global).minX)
                    }
                    // le zIndex est de 0 pour que la cam reste derrière les autres tabs, les autres tabs ont un zIndex de 1
                    .zIndex(0)
                    
                    // Troisième tab // TODO
                    Settings()
                    .zIndex(1)
                }
                // L'offset correspond au "defilement" entre les tabs et est déterminé par le geste de drag initialisé plus bas, le max et le min sert à ce qu'on ne puisse pas aller au dela du premier tab à gauche et au dela du dernier tab à droite
                .offset(x: max(
                    min(
                        0,
                        (-geo.size.width * CGFloat(currentIndex)) + scrollOffset),
                    -geo.size.width * CGFloat(tabs.count - 1)))
                // Les 3 tabs prendront au total la taille de l'écran * 3 (le nombre de tabs) pour que chaque tab prennent la taille de l'écran en entier
                .frame(width: geo.size.width*CGFloat(tabs.count))
                // Initialisation du geste de drag pour determiner l'offset et donc la navigation entre les tabs
                .gesture(DragGesture().updating($scrollOffset, body: { value, out, _ in
                    // Le out correspond à la variable scrollOffset et est égale à la distance parcouru pendant le drag pour avoir un effet de défilement
                    out = value.translation.width
                }).onEnded({ val in
                    // Lorsque le drag est terminé, on voit où on est mais en utilisant le "predictedEndTranslation" qui permet de prédire où se serait arrêté le drag avec la vélocité actuel. On prend ça en compte pour que même si le offset dépasse pas la moité de l'écran, si le user fait un mouvement assez rapide que ça puisse quand même changer de tab (big brain)
                    let offsetX = max(-geo.size.width,min(val.predictedEndTranslation.width, geo.size.width))
                    // On calcule le progress pour voir si le défilement est allé assez loin pour changer de tab
                    let progress = -offsetX / geo.size.width
                    // On arrondi : si c'est 0.4 ça sera arrondi à 0 et on change pas de tab et inversement si c'est 0.6 ça sera arrondi à 1 et ça change de tab
                    let roundProgress = progress.rounded()
                    
                    // On met à jour l'index du tab pour le changer
                    currentIndex = max(0, min(currentIndex + Int(roundProgress), tabs.count - 1))
                }))
            }
            // L'animation de changement de tab avec du easeOut pour que ça soit smooth
            .animation(.easeOut, value: scrollOffset == 0)
            
            // Le VStack sera composé d'un spacer() qui prend tout l'espace disponible en haut de l'écran pour mettre la navbar (ZStack) en bas de l'écran
            VStack{
                Spacer()
                
                // La navbar
                ZStack{
                    // Le background de la navbar
                    Rectangle()
                        .fill(Color(hex: 0x1c1c1c))
                        .frame(height: 100)
                        .clipShape(RoundedCorner(cornerRadius: 30, corners: [.topLeft, .topRight]))
                    
                    // Les 3 tabs de la navbar qui ont un spacer au debut, à la fin et entre chaque icones pour les répartir équitablement
                    HStack{
                        Spacer()
                        
                        // Une forloop qui met un Bouton avec l'image qui correspond au tab pour chaques tabs
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

// Commentaires //TODO
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
                        DispatchQueue.global(qos: .default).async {
                            camera.flipCam()
                        }
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
            if(!inPreview){
                DispatchQueue.global(qos: .default).async {
                    camera.Check()
                }
            }
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
            print("try to flip")
            var videoInput: AVCaptureDeviceInput?
            if(backCam){
                if(frontCamDevice != nil){
                    videoInput = try AVCaptureDeviceInput(device: frontCamDevice!)
                }
            }else{
                if(backCamDevice != nil){
                    videoInput = try AVCaptureDeviceInput(device: backCamDevice!)
                }
            }
            self.backCam.toggle()
            
            self.session.beginConfiguration()
            
            if(videoInput != nil){
                self.session.removeInput(self.session.inputs.first!)
                self.session.addInput(videoInput!)
            }
            print("finished")
            self.session.commitConfiguration()
        } catch {
            print("Erreur lors de la configuration de l'entrée vidéo : \(error.localizedDescription)")
        }
    }
    
    func Check(){
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
                self.setUp()
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
            print("begin setup")
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
            
            let frontCamera = frontDevices.isEmpty ? nil : frontDevices.first
            //let backCamera = backDevices.isEmpty ? nil : backDevices.last
            let backCamera = backDevices.isEmpty ? nil : AVCaptureDevice.default(for: .video)
            
            frontCamDevice = frontCamera
            backCamDevice = backCamera
            
            if(backCamera != nil){
                let input = try AVCaptureDeviceInput(device: backCamera!)
                
                if self.session.canAddInput(input){
                    self.session.addInput(input)
                }
            }
            
            if self.session.canAddOutput(self.output){
                self.session.addOutput(self.output)
            }
            
            self.session.commitConfiguration()
            print("commited configuration")
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
