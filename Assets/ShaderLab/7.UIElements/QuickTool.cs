using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.UIElements;
using Button = UnityEngine.UIElements.Button;

public class QuickTool : EditorWindow
{
    [MenuItem("QuickTool/Open _%#T")]
    public static void ShowWindow()
    {
        // Opens the window, otherwise focuses it if it’s already open.
        var window = GetWindow<QuickTool>();

        // Adds a title to the window.
        window.titleContent = new GUIContent("QuickTool");

        // Sets a minimum size to the window.
        window.minSize = new Vector2(250, 50);
    }
    
    private void OnEnable()
    {
        // Reference to the root of the window.
        var root = rootVisualElement;
        var vt = Resources.Load<VisualTreeAsset>("QuickTool_Main");
        vt.CloneTree(root);

        var tollbtns = root.Query<Button>();
        tollbtns.ForEach(SetupButton);

        // var button = new Button(){text = "Button Test"};
        //
        // // Gives it some style.
        // button.style.width = 160;
        // button.style.height = 30;
        //
        // // Adds it to the root.
        // root.Add(button);

    }

    private void SetupButton(Button button)
    {
        var icon = button.Query(className: "quicktool-button-icon");
        var iconPath = "Icons" + button.parent.name + "-icon";
        var iconAsset = Resources.Load<Texture2D>(iconPath);
        button.style.backgroundImage = iconAsset;
        button.clickable.clicked += () => { };
        button.tooltip = button.parent.name;
    }
}