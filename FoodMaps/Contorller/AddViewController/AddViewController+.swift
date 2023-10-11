//
//  AddViewController+.swift
//  FoodMaps
//
//  Created by Hemg on 10/11/23.
//

extension AddViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .placeholderText {
            textView.text = nil
            textView.textColor = .label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "음식점 내용 입력하는 곳입니다."
            textView.textColor = .placeholderText
        }
    }
}
