import WidgetGUI
import VisualAppBase

public class SearchResultsView: SingleChildWidget {

    @Observable private var query: String

    public init(query observableQuery: Observable<String>) {
        
        // TODO: this would allow modifying the thing passed as argument from here, maybe better do a one way binding instead
        self._query = observableQuery

        super.init()

        _ = self._query.onChanged { [unowned self] _ in

            invalidateChild()
        }
    }

    override public func buildChild() -> Widget {

        Text(query)
    }
}