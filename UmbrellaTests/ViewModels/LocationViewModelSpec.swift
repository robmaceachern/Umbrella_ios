//
//  LocationViewModelSpec.swift
//  UmbrellaTests
//
//  Created by Lucas Correa on 01/11/2018.
//  Copyright © 2018 Security First. All rights reserved.
//

import Foundation
import Quick
import Nimble

@testable import Umbrella

class LocationViewModelSpec: QuickSpec {
    
    override func spec() {
        describe("LocationViewModel") {
            
            beforeEach {
                
            }
            
            it("should create a new LocationViewModel") {
                let viewModel = LocationViewModel()
                expect(viewModel).toNot(beNil())
            }
            
            it("should do to geocode") {
                let viewModel = LocationViewModel()
                waitUntil(timeout: 30) { done in
                    viewModel.geocode(of: "Yemen", completion: {
                        expect(viewModel.cityArray.count) > 0
                        done()
                    }, failure: {
                        done()
                    })
                }
            }
            
            afterEach {
                
            }
        }
    }
}
