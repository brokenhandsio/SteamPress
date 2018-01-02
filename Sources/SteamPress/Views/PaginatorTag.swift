////import Core
//import Leaf
//
//final class PaginatorTag: Tag {
//    public enum Error: Swift.Error {
//        case expectedOneArgument(got: Int)
//        case expectedVariable
//        case expectedValidPaginator
//    }
//
//    fileprivate let blogPathCreator: BlogPathCreator
//    fileprivate let paginationLabel: String?
//    fileprivate let useBootstrap4: Bool
//
//    init(blogPathCreator: BlogPathCreator, paginationLabel: String? = nil, useBootstrap4: Bool = true) {
//        self.blogPathCreator = blogPathCreator
//        self.paginationLabel = paginationLabel
//        self.useBootstrap4 = useBootstrap4
//    }
//
//    let name = "paginator"
//
//    func run(tagTemplate: TagTemplate, arguments: ArgumentList) throws -> Node? {
//        guard arguments.count == 1, let argument = arguments.list.first else {
//            throw Error.expectedOneArgument(got: arguments.count)
//        }
//
//        guard case .variable(_, let value) = argument else {
//            throw Error.expectedVariable
//        }
//
//        guard let paginator = value?["pagination"]?.object else {
//            throw Error.expectedValidPaginator
//        }
//
//        guard let currentPage = paginator["current_page"]?.int,
//            let totalPages = paginator["total_pages"]?.int else {
//                return nil
//        }
//
//        return buildNavigation(currentPage: currentPage, totalPages: totalPages, previousPage: paginator["previous_page"]?.string, nextPage: paginator["next_page"]?.string)
//    }
//
//    func shouldRender(stem: Stem, context: Context, tagTemplate: TagTemplate, arguments: [Argument], value: Node?) -> Bool {
//        return true
//    }
//}
//
//extension PaginatorTag {
//
//    func buildBackButton(url: String?) -> Bytes {
//        guard let url = url else {
//            return buildLink(title: "«", active: false, link: nil, disabled: true).bytes
//        }
//
//        return buildLink(title: "«", active: false, link: url, disabled: false).bytes
//    }
//
//    func buildForwardButton(url: String?) -> Bytes {
//        guard let url = url else {
//            return buildLink(title: "»", active: false, link: nil, disabled: true).bytes
//        }
//
//        return buildLink(title: "»", active: false, link: url, disabled: false).bytes
//    }
//
//    func buildLinks(currentPage: Int, count: Int) -> Bytes {
//        var bytes: Bytes = []
//
//        if count == 0 {
//            return bytes
//        }
//
//        for i in 1...count {
//            if i == currentPage {
//                bytes += buildLink(title: "\(i)", active: true, link: nil, disabled: false).bytes
//            } else {
//                bytes += buildLink(title: "\(i)", active: false, link: "?page=\(i)", disabled: false).bytes
//            }
//        }
//
//        return bytes
//    }
//
//    func buildNavigation(currentPage: Int, totalPages: Int, previousPage: String?, nextPage: String?) -> Node {
//        var bytes: Bytes = []
//
//        let navClass: String
//        let ulClass: String
//
//        if useBootstrap4 {
//            navClass = "paginator"
//            ulClass = "pagination justify-content-center"
//        } else {
//            navClass = "paginator text-center"
//            ulClass = "pagination"
//        }
//
//        var headerString = "<nav class=\"\(navClass)\""
//        if let ariaLabel = paginationLabel {
//            headerString += " aria-label=\"\(ariaLabel)\""
//        }
//        headerString += ">\n<ul class=\"\(ulClass)\">\n"
//        let header = headerString.bytes
//        let footer = "</ul>\n</nav>".bytes
//
//        bytes += header
//
//        bytes += buildBackButton(url: previousPage)
//
//        bytes += buildLinks(currentPage: currentPage, count: totalPages)
//
//        bytes += buildForwardButton(url: nextPage)
//
//        bytes += footer
//
//        return .bytes(bytes)
//    }
//
//    func buildLink(title: String, active: Bool, link: String?, disabled: Bool) -> String {
//        let activeSpan = "<span class=\"sr-only\">(current)</span>"
//
//        let linkClass: String?
//        let liClass: String?
//
//        if useBootstrap4 {
//            linkClass = "page-link"
//            liClass = "page-item"
//        } else {
//            linkClass = nil
//            liClass = nil
//        }
//
//        var linkString = "<li"
//
//        if active || disabled || liClass != nil {
//            linkString += " class=\""
//
//            if active {
//                linkString += "active"
//            }
//            if disabled {
//                linkString += "disabled"
//            }
//
//            if let liClass = liClass {
//                if active || disabled {
//                    linkString += " "
//                }
//                linkString += "\(liClass)"
//            }
//
//            linkString += "\""
//        }
//
//        linkString += ">"
//
//        if let link = link {
//            linkString += "<a href=\"\(link)\""
//
//            if let linkClass = linkClass {
//                linkString += " class=\"\(linkClass)\""
//            }
//
//            if title == "«" {
//                linkString += " rel=\"prev\" aria-label=\"Previous\"><span aria-hidden=\"true\">«</span><span class=\"sr-only\">Previous</span>"
//            } else if title == "»" {
//                linkString += " rel=\"next\" aria-label=\"Next\"><span aria-hidden=\"true\">»</span><span class=\"sr-only\">Next</span>"
//            } else {
//                linkString += ">\(title)"
//            }
//
//            linkString += "</a>"
//        } else {
//            linkString += "<span"
//
//            if let linkClass = linkClass {
//                linkString += " class=\"\(linkClass)\""
//            }
//
//            if title == "«" {
//                linkString += " aria-label=\"Previous\" aria-hidden=\"true\">«</span><span class=\"sr-only\">Previous</span>"
//            } else if title == "»" {
//                linkString += " aria-label=\"Next\" aria-hidden=\"true\">»</span><span class=\"sr-only\">Next</span>"
//            } else {
//                linkString += ">\(title)</span>"
//
//                if active {
//                    linkString += activeSpan
//                }
//            }
//        }
//
//        linkString += "</li>\n"
//
//        return linkString
//    }
//}
//
//extension PaginatorTag.Error: Equatable {
//    static func == (lhs: PaginatorTag.Error, rhs: PaginatorTag.Error) -> Bool {
//        switch (lhs, rhs) {
//        case (.expectedOneArgument(let a), .expectedOneArgument(let b)):
//            return a == b
//
//        case
//        (.expectedVariable, .expectedVariable),
//        (.expectedValidPaginator, .expectedValidPaginator):
//            return true
//
//        default:
//            return false
//        }
//    }
//}

