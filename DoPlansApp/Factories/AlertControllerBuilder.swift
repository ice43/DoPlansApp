//
//  AlertControllerBuilder.swift
//  DoPlansApp
//
//  Created by Serge Bowski on 2/15/24.
//

import UIKit

/**
 Для создания `UIAlertController` с разными полями в зависимости от контекста редактирования (список задач или отдельная задача) можно использовать паттерн проектирования "Строитель" (Builder pattern). Этот паттерн позволяет создавать сложные объекты с помощью последовательного вызова методов строителя, предоставляя гибкость в конфигурировании объекта.
 */
final class AlertControllerBuilder {
    private let alertController: UIAlertController
    
    /**
         Инициализирует экземпляр `AlertControllerBuilder` с указанным заголовком и сообщением.
         
         - Parameters:
           - title: Заголовок предупреждения.
           - message: Текст сообщения предупреждения.
         */
    init(title: String, message: String) {
        alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let attributedTitle = NSAttributedString(
            string: title,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
        alertController.setValue(attributedTitle, forKey: "attributedTitle")

        // Создание атрибутированной строки для сообщения с белым цветом текста
        let attributedMessage = NSAttributedString(
            string: message,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
        alertController.setValue(attributedMessage, forKey: "attributedMessage")
    }
    
    /**
         Создает текстовое поле с указанным текстом и плейсхолдером.
         
         - Parameters:
            - placeholder: Определяет плейсхолдер для текстового поля
            - text: Определяет текст для отображения в текстовом поле
         - Returns: Ссылка на текущий экземпляр `AlertControllerBuilder` для цепочки вызовов.
         */
    func setTextField(withPlaceholder placeholder: String, andText text: String?) -> AlertControllerBuilder {
        alertController.addTextField { textField in
            textField.placeholder = placeholder
            textField.text = text
        }
        return self
    }
    
    /**
         Добавляет действие в `UIAlertController`.
         
         - Parameters:
           - title: Заголовок действия.
           - style: Стиль действия.
           - handler: Замыкание, вызываемое при выборе действия. Принимает заголовок задачи и заголовок заметки в качестве параметров.
         - Returns: Ссылка на текущий экземпляр `AlertControllerBuilder` для цепочки вызовов.
         */
    @discardableResult
    func addAction(title: String, style: UIAlertAction.Style, handler: ((String, String) -> Void)? = nil) -> AlertControllerBuilder {
            let action = UIAlertAction(title: title, style: style) { [weak alertController] _ in
                guard let title = alertController?.textFields?.first?.text else { return }
                guard !title.isEmpty else { return }
                let note = alertController?.textFields?.last?.text
                handler?(title, note ?? "")
            }
            alertController.addAction(action)
            return self
        }
    
    func setBlurView() {
        let container = alertController.view.subviews.first!.subviews.first!.subviews.first!
        container.backgroundColor = UIColor.black.withAlphaComponent(0.6)

        // Создание эффекта размытого фона
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = container.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // Добавление размытого фона в контейнер
        container.insertSubview(blurView, at: 0)
    }
    
    /**
         Создает и возвращает экземпляр `UIAlertController`, созданный на основе установленных параметров и действий.
         
         - Returns: Экземпляр `UIAlertController`.
         */
    func build() -> UIAlertController {
        alertController
    }
}
