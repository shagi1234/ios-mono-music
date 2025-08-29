//
//  HomeVM.swift
//  Music-app
//
//  Created by Ширин Янгибаева on 15.08.2023.
//

import Foundation
import Resolver
import AVFoundation

class HomeVM: ObservableObject {
    @Injected var repo: HomeRepo

    @Published var inProgress = false
    @Published var noConnection = false
    @Published var data: HomeModel?

    
    init(){
        getData()
    }
    
    
    func getData(){
        inProgress = true
        noConnection = false
        
        repo.getHome { [weak self] resp in
            self?.inProgress.toggle()
            
            switch resp {
            case .success(let success):
                self?.data = success

            case .failure(_):
                self?.noConnection = true
            }
        }
    }
}
