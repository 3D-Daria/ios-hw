//
//  NoteCell.swift
//  dddavidkoPW3
//
//  Created by Daria D on 20.12.2022.
//

import UIKit

final class NoteCell : UITableViewCell {
    static let reuseIdentifier = "NoteCell"
    
    public func configure(_ note: ShortNote) {
        self.textLabel?.text = note.text
    }
}
