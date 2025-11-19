"use client"

import * as React from "react"
import {
  BookOpen,
  Bot,
  Frame,
} from "lucide-react"

import { GraphiteLogo } from "@/components/ui/graphite-logo"
import { NavMain } from "@/components/nav-main"
import { NavProjects } from "@/components/nav-projects"
import { NavUser } from "@/components/nav-user"
import { TeamSwitcher } from "@/components/team-switcher"
import {
  Sidebar,
  SidebarContent,
  SidebarFooter,
  SidebarHeader,
  SidebarRail,
} from "@/components/ui/sidebar"

interface AppSidebarProps extends React.ComponentProps<typeof Sidebar> {
  user: {
    name: string
    email: string
    image: string
  }
}

// This is sample data.
const data = {
  teams: [
    {
      name: "Graphite",
      logo: GraphiteLogo,
      plan: "Enterprise",
    }
  ],
  navMain: [
    {
      title: "Models",
      url: "#",
      icon: Bot,
      items: [
        {
          title: "OpenAI",
          url: "#",
        }
      ],
    },
    {
      title: "Documentation",
      url: "#",
      icon: BookOpen,
      items: [
        {
          title: "Introduction",
          url: "#",
        }
      ],
    }
  ],
  projects: [
    {
      name: "BI",
      url: "#",
      icon: Frame,
    }
  ],
}

export function AppSidebar({ user, ...props }: React.ComponentProps<typeof Sidebar> & { user: { name: string; email: string; image: string }}) {
  return (
    <Sidebar collapsible="icon" {...props}>
      <SidebarHeader>
        <TeamSwitcher teams={data.teams} />
      </SidebarHeader>
      <SidebarContent>
        <NavMain items={data.navMain} />
        <NavProjects projects={data.projects} />
      </SidebarContent>
      <SidebarFooter>
        <NavUser user={user} />
      </SidebarFooter>
      <SidebarRail />
    </Sidebar>
  )
}
