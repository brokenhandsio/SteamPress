import TemplateKit

public final class PaginatorTag: TagRenderer {
    public enum Error: Swift.Error {
        case expectedPaginationInformation
    }

    let paginationLabel: String?

    public init(paginationLabel: String? = nil) {
        self.paginationLabel = paginationLabel
    }

    public static let name = "paginator"
    
    public func render(tag: TagContext) throws -> EventLoopFuture<TemplateData> {
        try tag.requireNoBody()
                
        guard let paginationInformaton = tag.context.data.dictionary?["paginationTagInformation"] else {
            throw Error.expectedPaginationInformation
        }
        
        guard let currentPage = paginationInformaton.dictionary?["currentPage"]?.int,
            let totalPages = paginationInformaton.dictionary?["totalPages"]?.int else {
            throw Error.expectedPaginationInformation
        }
        
        let currentQuery = paginationInformaton.dictionary?["currentQuery"]?.string
        
        let previousPage: String?
        let nextPage: String?
        
        if currentPage == 1 {
            previousPage = nil
        } else {
            let previousPageNumber = currentPage - 1
            previousPage = buildButtonLink(currentQuery: currentQuery, pageNumber: previousPageNumber)
        }
        
        if currentPage == totalPages {
            nextPage = nil
        } else {
            let nextPageNumber = currentPage + 1
            nextPage = buildButtonLink(currentQuery: currentQuery, pageNumber: nextPageNumber)
        }
        
        let data = buildNavigation(currentPage: currentPage, totalPages: totalPages, previousPage: previousPage, nextPage: nextPage, currentQuery: currentQuery)
        return tag.eventLoop.future(data)
        
    }
}

extension PaginatorTag {
    
    func buildButtonLink(currentQuery: String?, pageNumber: Int) -> String {
        var urlComponents = URLComponents()
        urlComponents.query = currentQuery
        if (urlComponents.queryItems?.contains { $0.name == "page" }) ?? false {
            urlComponents.queryItems?.removeAll { $0.name == "page" }
        }
        let pageQuery = URLQueryItem(name: "page", value: "\(pageNumber)")
        urlComponents.queryItems?.append(pageQuery)
        return "?\(urlComponents.query ?? "")"
    }

    func buildBackButton(url: String?) -> String {
        guard let url = url else {
            return buildLink(title: "«", active: false, link: nil, disabled: true)
        }

        return buildLink(title: "«", active: false, link: url, disabled: false)
    }

    func buildForwardButton(url: String?) -> String {
        guard let url = url else {
            return buildLink(title: "»", active: false, link: nil, disabled: true)
        }

        return buildLink(title: "»", active: false, link: url, disabled: false)
    }

    func buildLinks(currentPage: Int, count: Int, currentQuery: String?) -> String {
        var links = ""

        if count == 0 {
            return links
        }

        for i in 1...count {
            if i == currentPage {
                links += buildLink(title: "\(i)", active: true, link: nil, disabled: false)
            } else {
                let link = buildButtonLink(currentQuery: currentQuery, pageNumber: i)
                links += buildLink(title: "\(i)", active: false, link: link, disabled: false)
            }
        }

        return links
    }

    func buildNavigation(currentPage: Int, totalPages: Int, previousPage: String?, nextPage: String?, currentQuery: String?) -> TemplateData {
        
        var result = ""

        let navClass = "paginator"
        let ulClass = "pagination justify-content-center"

        var header = "<nav class=\"\(navClass)\""
        if let ariaLabel = paginationLabel {
            header += " aria-label=\"\(ariaLabel)\""
        }
        header += ">\n<ul class=\"\(ulClass)\">\n"
        let footer = "</ul>\n</nav>"

        result += header

        result += buildBackButton(url: previousPage)

        result += buildLinks(currentPage: currentPage, count: totalPages, currentQuery: currentQuery)

        result += buildForwardButton(url: nextPage)

        result += footer

        return TemplateData.string(result)
    }

    func buildLink(title: String, active: Bool, link: String?, disabled: Bool) -> String {
        let activeSpan = "<span class=\"sr-only\">(current)</span>"

        let linkClass = "page-link"
        let liClass = "page-item"
        
        var linkString = "<li"

        if active || disabled {
            linkString += " class=\""

            if active {
                linkString += "active"
            }
            if disabled {
                linkString += "disabled"
            }

            if active || disabled {
                linkString += " "
            }
            linkString += "\(liClass)"

            linkString += "\""
        }

        linkString += ">"

        if let link = link {
            linkString += "<a href=\"\(link)\" class=\"\(linkClass)\""

            if title == "«" {
                linkString += " rel=\"prev\" aria-label=\"Previous\"><span aria-hidden=\"true\">«</span><span class=\"sr-only\">Previous</span>"
            } else if title == "»" {
                linkString += " rel=\"next\" aria-label=\"Next\"><span aria-hidden=\"true\">»</span><span class=\"sr-only\">Next</span>"
            } else {
                linkString += ">\(title)"
            }

            linkString += "</a>"
        } else {
            linkString += "<span class=\"\(linkClass)\""

            if title == "«" {
                linkString += " aria-label=\"Previous\" aria-hidden=\"true\">«</span><span class=\"sr-only\">Previous</span>"
            } else if title == "»" {
                linkString += " aria-label=\"Next\" aria-hidden=\"true\">»</span><span class=\"sr-only\">Next</span>"
            } else {
                linkString += ">\(title)</span>"

                if active {
                    linkString += activeSpan
                }
            }
        }

        linkString += "</li>\n"

        return linkString
    }
}
