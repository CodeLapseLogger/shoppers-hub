import 'package:flutter/material.dart';

class ManagedProductItemWidget extends StatelessWidget {
  final String productName;
  final String productImageUrl;

  // Constructor initialized with data only needed by this widget. So, makes sense to pass on data through the constructor
  // as it is local state, rather than the provider/listener method which is better suited for global state.
  ManagedProductItemWidget({
    @required this.productName,
    @required this.productImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(
              productImageUrl,
            ),
          ),
          title: Text(
            productName,
          ),
          trailing: Container(
            width: 100,
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: Theme.of(context).errorColor,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
        Divider(),
      ],
    );
  }
}
