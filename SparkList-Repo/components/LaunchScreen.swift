//
//  LaunchScreen.swift
//  SparkList
//
//  Created by User on 12/10/23.
//
import SwiftUI
struct LaunchScreen: View {

    var body: some View {
        ZStack {
            Color("Color 4")
            //            HStack{
            //                Text("Spark")
            //                    .font(.largeTitle) // Adjust font size and style
            //
            //                    .fontWeight(.bold) // Adjust font weight
            //                    .foregroundColor(.yellow) // Adjust text color
            //                    .padding(.horizontal, -5)
            //
            //                    .padding(.top, 50)
            //                Text("List")
            //                    .font(.largeTitle) // Adjust font size and style
            //                    .fontWeight(.bold) // Adjust font weight
            //                    .foregroundColor(.blue) // Adjust text color
            //                    .padding(.horizontal, -5)
            //                    .padding(.top, 50)
            //
            //            }

            Image("time-splashscreen")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding()
        }
//            Text("Time Turner-Inner")
//                .font(.title2)
//                .fontWeight(.semibold)
//                .foregroundColor(.black)
//                .padding(.bottom, 50)
//          

        .edgesIgnoringSafeArea(.all)
        .background(Color("Color 4"))

    }
}
